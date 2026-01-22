import Foundation
import CoreLocation
import WeatherKit

@MainActor
final class DateWeatherViewModel: ObservableObject {

    @Published var dateText: String = ""
    @Published var todayText: String = ""
    @Published var weatherText: String = "날씨 불러오는 중…"

    private let locationProvider = LocationProvider()
    private let weatherService = WeatherService()

    func onAppear() async {
        updateDateTexts()
        await refreshWeather()
    }

    func refreshDateOnly() {
        updateDateTexts()
    }

    func refreshWeather() async {
        do {
            weatherText = "날씨 불러오는 중…"

            let loc = try await locationProvider.requestLocationOnce()
            let weather = try await weatherService.weather(for: loc)

            let conditionText = weather.currentWeather.condition.koreanText
            let tempC = Int(weather.currentWeather.temperature.converted(to: .celsius).value.rounded())

            weatherText = "\(conditionText) \(tempC)°C"
        } catch let e as LocationProvider.LocationError {
            weatherText = e.localizedDescription
        } catch {
            // WeatherKit/네트워크/권한 등 기타 에러
            weatherText = "날씨 가져오기 실패"
        }
    }

    private func updateDateTexts() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"

        dateText = formatter.string(from: now)
        todayText = "오늘"
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
