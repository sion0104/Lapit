import Foundation

struct SaveDailyPlanReq: Encodable {
    let checkDate: String
    let plan: String
    let memo: String
}

struct DailyPlanSavePayload: Decodable {
    let id: Int
}

extension APIClient {
    func saveDailyPlan(checkDate: String, plan: String, memo: String) async throws -> CommonResponse<DailyPlanSavePayload> {
        let body = SaveDailyPlanReq(checkDate: checkDate, plan: plan, memo: memo)
        return try await post("/v1/daily-plan", body: body)
    }
}

