import Foundation

struct WorkoutSaveRequest: Encodable {
    let workoutType: String
    let checkDate: String            // yyyy-MM-dd
    let startTime: String            // yyyy-MM-dd HH:mm:ss
    let endTime: String              // yyyy-MM-dd HH:mm:ss
    let durationSec: Int

    let totalDistance: Double        // meters
    let totalCaloriesKcal: Double    // kcal

    let avgHeartRate: Double         // bpm
    let avgSpeed: Double             // m/s
    let maxSpeed: Double             // m/s
    let avgPower: Double

    let details: [WorkoutDetailRequest]
}

struct WorkoutDetailRequest: Encodable {
    let measureAt: String            // yyyy-MM-dd HH:mm:ss
    let heartRate: Double            // bpm
    let speed: Double               // m/s
    let power: Double?              // optional
}


enum WorkoutDateFormatter {
    static func checkDateString(_ date: Date) -> String {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "ko_KR")
        df.timeZone = TimeZone(identifier: "Asia/Seoul")
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: date)
    }

    private static let backendDateTime: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "ko_KR")
        df.timeZone = TimeZone(identifier: "Asia/Seoul")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()

    static func backendDateTimeString(_ date: Date) -> String {
        backendDateTime.string(from: date)
    }
    
    static func backendStringDate(_ string: String) -> Date? {
        if let d = backendDateTime.date(from: string) { return d }

        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "ko_KR")
        df.timeZone = TimeZone(identifier: "Asia/Seoul")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return df.date(from: string)
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

