import Foundation

struct WorkoutDailyPayload: Decodable {
    // 서버에서 null 오는 케이스가 있었으니 optional로 안전하게
    let userId: Int
    let checkDate: String                 // yyyy-MM-dd

    // SaveRequest 기반
    let workoutType: String               // e.g. "cycling"
    let startTime: String                 // yyyy-MM-dd HH:mm:ss
    let endTime: String                   // yyyy-MM-dd HH:mm:ss
    let durationSec: Int                  // sec

    let totalDistance: Double             // meters
    let totalCaloriesKcal: Double         // kcal

    let avgHeartRate: Double              // bpm
    let avgSpeed: Double                  // m/s
    let maxSpeed: Double                  // m/s
    let avgPower: Double                  // watt (or 0 if missing)

    // 서버에 따라 키가 details / workoutMeasureList 일 수 있어 매핑
    let details: [WorkoutDetail]

    // 비교/부가 필드(서버에 있으면 쓰고, 없으면 0으로)
    let prevTotalCaloriesKcal: Double
    let prevRideSec: Int

    // 기존 그대로 유지(선택)
    let dailyCondition: DailyCondition?
    let dailyPlan: DailyPlan?
    let weekPlan: WeekPlan?

    enum CodingKeys: String, CodingKey {
        case userId, checkDate
        case workoutType, startTime, endTime, durationSec
        case totalDistance, totalCaloriesKcal
        case avgHeartRate, avgSpeed, maxSpeed, avgPower
        case details
        case workoutMeasureList // 서버가 이 키로 주는 경우
        case prevTotalCaloriesKcal, prevRideSec
        case dailyCondition, dailyPlan, weekPlan
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        self.userId = c.decodeLossyInt(.userId, default: 0)
        self.checkDate = (try? c.decode(String.self, forKey: .checkDate)) ?? ""

        self.workoutType = (try? c.decode(String.self, forKey: .workoutType)) ?? ""
        self.startTime = (try? c.decode(String.self, forKey: .startTime)) ?? ""
        self.endTime = (try? c.decode(String.self, forKey: .endTime)) ?? ""
        self.durationSec = c.decodeLossyInt(.durationSec, default: 0)

        self.totalDistance = c.decodeLossyDouble(.totalDistance, default: 0)
        self.totalCaloriesKcal = c.decodeLossyDouble(.totalCaloriesKcal, default: 0)

        self.avgHeartRate = c.decodeLossyDouble(.avgHeartRate, default: 0)
        self.avgSpeed = c.decodeLossyDouble(.avgSpeed, default: 0)
        self.maxSpeed = c.decodeLossyDouble(.maxSpeed, default: 0)
        self.avgPower = c.decodeLossyDouble(.avgPower, default: 0)

        // ✅ details 키가 없으면 workoutMeasureList를 details로 디코딩
        if let d = try? c.decode([WorkoutDetail].self, forKey: .details) {
            self.details = d
        } else if let d = try? c.decode([WorkoutDetail].self, forKey: .workoutMeasureList) {
            self.details = d
        } else {
            self.details = []
        }

        self.prevTotalCaloriesKcal = c.decodeLossyDouble(.prevTotalCaloriesKcal, default: 0)
        self.prevRideSec = c.decodeLossyInt(.prevRideSec, default: 0)

        self.dailyCondition = try? c.decode(DailyCondition.self, forKey: .dailyCondition)
        self.dailyPlan = try? c.decode(DailyPlan.self, forKey: .dailyPlan)
        self.weekPlan = try? c.decode(WeekPlan.self, forKey: .weekPlan)
    }
}

struct WorkoutDetail: Decodable, Identifiable {
    // 응답에 id가 없을 수 있으니 안정적으로 UUID 생성
    let id: String
    let measureAt: String            // yyyy-MM-dd HH:mm:ss
    let heartRate: Double            // bpm
    let speed: Double                // m/s
    let power: Double?               // optional

    enum CodingKeys: String, CodingKey {
        case id, measureAt, heartRate, speed, power
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        // id가 없으면 measureAt을 id로 쓰고, 그것도 없으면 UUID
        let rawId = (try? c.decode(String.self, forKey: .id))
        let measureAt = (try? c.decode(String.self, forKey: .measureAt)) ?? ""
        self.id = rawId ?? (measureAt.isEmpty ? UUID().uuidString : measureAt)

        self.measureAt = measureAt
        self.heartRate = c.decodeLossyDouble(.heartRate, default: 0)
        self.speed = c.decodeLossyDouble(.speed, default: 0)

        // power는 Double? (문자/정수로 오는 것도 안전 변환)
        if let v = try? c.decode(Double.self, forKey: .power) {
            self.power = v
        } else if let v = try? c.decode(Int.self, forKey: .power) {
            self.power = Double(v)
        } else if let s = try? c.decode(String.self, forKey: .power), let d = Double(s) {
            self.power = d
        } else {
            self.power = nil
        }
    }
}

struct WorkoutMeasure: Decodable, Identifiable {
    let id: Int
    let measureAt: String
    let heartRate: Double
    let speed: Double
    let power: Int?
}

struct DailyCondition: Decodable {
    let id: Int
    let checkDate: String
    let conditionScore: Int
    let moodScore: Int
    let fatigueScore: Int
    let recoveryState: String
    let painArea: String
}

struct DailyPlan: Decodable {
    let id: Int
    let checkDate: String
    let rideSec: Int?
    let plan: String
    let memo: String
}

struct WeekPlan: Decodable {
    let id: Int
    let checkDate: String
    let targetDistanceKm: Double
    let targetCaloriesKal: Int
    let targetWorkoutDays: Int
}

private extension KeyedDecodingContainer {
    func decodeLossyDouble(_ key: Key, default defaultValue: Double = 0) -> Double {
        if let v = try? decode(Double.self, forKey: key) { return v }
        if let v = try? decode(Int.self, forKey: key) { return Double(v) }
        if let v = try? decode(String.self, forKey: key), let d = Double(v) { return d }
        return defaultValue
    }

    func decodeLossyInt(_ key: Key, default defaultValue: Int = 0) -> Int {
        if let v = try? decode(Int.self, forKey: key) { return v }
        if let v = try? decode(Double.self, forKey: key) { return Int(v.rounded()) }
        if let v = try? decode(String.self, forKey: key), let i = Int(v) { return i }
        return defaultValue
    }
}

