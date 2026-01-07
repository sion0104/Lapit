import Foundation

extension APIClient {
    func deleteUser() async throws {
        let _: CommonResponseNoData = try await delete("/v1/user")
    }
}
