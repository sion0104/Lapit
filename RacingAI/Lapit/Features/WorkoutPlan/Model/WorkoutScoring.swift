import Foundation

enum WorkoutScoring {
    static func didWorkout(_ payload: WorkoutDailyPayload) -> Bool {
        let hasDetails = !payload.details.isEmpty
        let todayKcal = Int(payload.totalCaloriesKcal.rounded())
        return hasDetails || payload.durationSec > 0 || todayKcal > 0
    }

    static func score(from payload: WorkoutDailyPayload) -> Int {
        guard didWorkout(payload) else { return 0 }

        let avgSpeedKmh = payload.avgSpeed * 3.6
        return WorkoutScoreCalculator.calculate(
            avgSpeedKmh: avgSpeedKmh,
            avgPowerW: payload.avgPower,
            targetSpeedKmh: nil,
            targetPowerW: nil
        )
    }
}
