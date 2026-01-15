import Foundation

struct WorkoutSaveRequest: Encodable {
    let workoutType: String
    let checkDate: String            // yyyy-MM-dd
    let startTime: String            // ISO8601 + Z
    let endTime: String              // ISO8601 + Z
    let durationSec: Int

    let totalDistance: Double        // meters
    let totalCaloriesKcal: Double    // kcal

    let avgHeartRate: Double         // bpm
    let avgSpeed: Double             // m/s  ✅ 서버 스펙
    let maxSpeed: Double             // m/s  ✅ 서버 스펙
    let avgPower: Double

    let details: [WorkoutDetailRequest]
}

struct WorkoutDetailRequest: Encodable {
    let measureAt: String            // ISO8601 + Z
    let heartRate: Double            // bpm
    let speed: Double               // m/s ✅ 서버 스펙
    let power: Double?              // optional
}


enum WorkoutDateFormatter {
    private static let isoUTC: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    static func isoString(_ date: Date) -> String {
        isoUTC.string(from: date)
    }

    static func checkDateString(_ date: Date) -> String {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone.current
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: date)
    }
}

enum WorkoutTypeMapper {
    static func toServer(_ raw: String) -> String {
        switch raw.lowercased() {
        case "cycling", "cycle", "bike", "bicycle":
            return "cycling"
        case "running", "run":
            return "running"
        case "walking", "walk":
            return "walking"
        default:
            return raw
        }
    }
}

