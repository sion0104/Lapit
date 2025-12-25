import Foundation
import CoreLocation
import WeatherKit

final class DateWeatherViewModel: NSObject, ObservableObject {

    @Published var dateText: String = ""
    @Published var todayText: String = ""
    @Published var weatherText: String = "날씨 불러오는 중…"

    private let locationManager = CLLocationManager()
    private let weatherService = WeatherService()

    override init() {
        super.init()
        locationManager.delegate = self
        updateDateTexts()
    }

    // View에서 호출
    func onAppear() async {
        updateDateTexts()
        requestLocation()
    }

    func refreshDateOnly() {
        updateDateTexts()
    }

    private func requestLocation() {
        // 권한 상태에 따라 처리
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()

        case .restricted, .denied:
            Task { @MainActor in
                self.weatherText = "위치 권한 필요"
            }

        @unknown default:
            Task { @MainActor in
                self.weatherText = "권한 확인 불가"
            }
        }
    }

    private func updateDateTexts() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"

        // UI 업데이트는 MainActor에서
        Task { @MainActor in
            self.dateText = formatter.string(from: now)
            self.todayText = "오늘"
        }
    }

    private func fetchWeather(for location: CLLocation) async {
        do {
            let weather = try await weatherService.weather(for: location)

            let conditionText = weather.currentWeather.condition.koreanText
            let tempC = Int(weather.currentWeather.temperature.converted(to: .celsius).value.rounded())

            await MainActor.run {
                self.weatherText = "\(conditionText) \(tempC)°C"
            }
        } catch {
            await MainActor.run {
                self.weatherText = "날씨 가져오기 실패"
            }
        }
    }
}

extension DateWeatherViewModel: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            Task { @MainActor in
                self.weatherText = "위치 권한 필요"
            }
        default:
            break
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task {
            await self.fetchWeather(for: loc)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.weatherText = "위치 오류"
        }
    }
}

extension WeatherCondition {
    var koreanText: String {
        switch self {
        case .clear: return "맑음"
        case .mostlyClear: return "대체로 맑음"
        case .partlyCloudy: return "구름 조금"
        case .mostlyCloudy: return "대체로 흐림"
        case .cloudy: return "흐림"
        case .foggy: return "안개"
        case .haze: return "연무"
        case .smoky: return "연기"
        case .windy: return "바람"
        case .drizzle: return "이슬비"
        case .rain: return "비"
        case .heavyRain: return "폭우"
        case .snow: return "눈"
        case .heavySnow: return "폭설"
        case .sleet: return "진눈깨비"
        case .hail: return "우박"
        case .thunderstorms: return "천둥번개"
        default: return "날씨"
        }
    }
}
