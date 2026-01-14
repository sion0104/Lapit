import Foundation

struct DailyAIPlanPayload: Decodable {
    let plan: String?
}

typealias DailyAIPlanResponse = CommonResponse<DailyAIPlanPayload>
