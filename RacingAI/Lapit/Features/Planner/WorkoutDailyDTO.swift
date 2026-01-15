import Foundation

struct WorkoutDailyPayload: Decodable {
    let userId: Int
    let checkDate: String

    let avgHeartRate: Double
    let avgPower: Double
    let totalCaloriesKcal: Double

    let maxHeartRate: Double
    let minHeartRate: Double

    let avgSpeed: Double
    let maxSpeed: Double
    let minSpeed: Double

    let totalDistance: Double
    let prevTotalCaloriesKcal: Double

    let avgRideSec: Int?
    let prevRideSec: Int?

    let totalAvgPower: Double

    let workoutMeasureList: [WorkoutMeasure]

    let dailyCondition: DailyCondition?
    let dailyPlan: DailyPlan?
    let weekPlan: WeekPlan?
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
