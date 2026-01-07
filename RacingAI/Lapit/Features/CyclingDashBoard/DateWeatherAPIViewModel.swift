import Foundation
import CoreLocation

@MainActor
final class DateWeatherAPIViewModel: NSObject, ObservableObject {
    @Published var dateText: String = ""
    @Published var todayText: String = ""
    @Published var weatherText: String = "날씨 불러오는 중…"

    private let locationManager = CLLocationManager()
    private let locationDelegate = LocationDelegate()

    override init() {
        super.init()
        updateDateTexts()

        locationManager.delegate = locationDelegate
        locationDelegate.onAuthChanged = { [weak self] status in
            guard let self else { return }
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                self.locationManager.requestLocation()
            } else if status == .denied || status == .restricted {
                self.weatherText = "위치 권한 필요"
            }
        }
        locationDelegate.onLocation = { [weak self] loc in
            guard let self else { return }
            Task { await self.fetchWeatherOpenMeteo(for: loc) }
        }
        locationDelegate.onError = { [weak self] _ in
            self?.weatherText = "위치 오류"
        }
    }

    func onAppear() async {
        requestLocation()
    }

    func refreshDateOnly() {
        updateDateTexts()
    }

    private func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    private func updateDateTexts() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        dateText = formatter.string(from: now)
        todayText = "오늘"
    }

    private func fetchWeatherOpenMeteo(for location: CLLocation) async {
        do {
            let (conditionText, tempC) = try await OpenMeteoClient.fetchCurrentWeather(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude
            )
            self.weatherText = "\(conditionText) \(Int(tempC.rounded()))°C"
        } catch {
            self.weatherText = "날씨 가져오기 실패"
        }
    }
}

final class LocationDelegate: NSObject, CLLocationManagerDelegate {
    var onAuthChanged: ((CLAuthorizationStatus) -> Void)?
    var onLocation: ((CLLocation) -> Void)?
    var onError: ((Error) -> Void)?

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuthChanged?(manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last { onLocation?(loc) }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onError?(error)
    }
}

enum OpenMeteoClient {
    struct Response: Decodable {
        let current_weather: CurrentWeather

        struct CurrentWeather: Decodable {
            let temperature: Double
            let weathercode: Int
        }
    }

    static func fetchCurrentWeather(lat: Double, lon: Double) async throws -> (String, Double) {
        // current_weather=true 로 현재 날씨 가져오기
        let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current_weather=true"
        guard let url = URL(string: urlStr) else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(Response.self, from: data)

        let text = weatherCodeToKorean(decoded.current_weather.weathercode)
        return (text, decoded.current_weather.temperature)
    }

    static func weatherCodeToKorean(_ code: Int) -> String {
        switch code {
        case 0: return "맑음"
        case 1,2,3: return "구름"
        case 45,48: return "안개"
        case 51,53,55: return "이슬비"
        case 61,63,65: return "비"
        case 71,73,75: return "눈"
        case 80,81,82: return "소나기"
        case 95,96,99: return "뇌우"
        default: return "날씨"
        }
    }
}
