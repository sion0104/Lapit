import Foundation

enum MetricFormatter {
    static func metersToKmText(_ meters: Double?) -> String {
        guard let meters else { return "-- km" }
        let km = meters / 1000.0
        return String(format: "%.2f km", km)
    }

    static func speedMpsToKmhText(_ mps: Double?) -> String {
        guard let mps else { return "-- km/h" }
        let kmh = mps * 3.6
        return String(format: "%.1f km/h", kmh)
    }

    static func kcalText(_ kcal: Double?) -> String {
        guard let kcal else { return "--" }
        return String(format: "%.0f", kcal)
    }

    static func bpmInt(_ bpm: Double?) -> Int {
        Int((bpm ?? 0).rounded())
    }
}
