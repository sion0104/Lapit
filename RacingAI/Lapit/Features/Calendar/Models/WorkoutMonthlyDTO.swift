import Foundation

struct WorkoutMonthlyItemDTO: Decodable {
    let checkDate: String            // "2026-01-21"
    let avgHeartRate: Double?
    let avgPower: Double?
    let totalAvgPower: Double?
    let rideSec: Int?
    let maxHeartRate: Double?
}

typealias WorkoutMonthlyResponseDTO = CommonResponse<[WorkoutMonthlyItemDTO]>
