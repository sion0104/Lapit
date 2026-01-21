import Foundation

enum WorkoutScoreCalculator {

    /// TS = 100 - (속도편차율 * 30 + 파워편차율 * 40)
    ///
    /// - speed: km/h
    /// - power: W
    ///
    /// 편차율은 0~1 비율 (10% 차이 = 0.10)
    static func calculate(
        avgSpeedKmh: Double,
        avgPowerW: Double,
        targetSpeedKmh: Double?,
        targetPowerW: Double?
    ) -> Int {

        func deviationRate(actual: Double, target: Double?) -> Double {
            guard let target, target > 0 else { return 0 }
            guard actual > 0 else { return 1 }
            return abs(actual - target) / target
        }

        let speedDev = deviationRate(actual: avgSpeedKmh, target: targetSpeedKmh)
        let powerDev = deviationRate(actual: avgPowerW, target: targetPowerW)

        let weightedPenalty = speedDev * 30 + powerDev * 40
        let rawScore = 100 - weightedPenalty

        let clamped = min(max(rawScore, 0), 100)
        return Int(clamped.rounded())
    }
}
