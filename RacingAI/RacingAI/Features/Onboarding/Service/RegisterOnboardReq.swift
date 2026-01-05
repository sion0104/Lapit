import Foundation

struct SignUpOnboardItem: Codable {
    let questionCodedId: Int
    let answerCodeId: Int
    let answerText: String?
}

struct RegisterOnboardReq: Codable {
    let userId: Int
    let height: Double
    let weight: Double
    let bmi: Double
    let onboardList: [SignUpOnboardItem]
}

struct UserIdPayload: Decodable {
    let userID: Int
}
