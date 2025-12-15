import Foundation

struct GetUserInfoRes: Decodable {
    let status: String
    let message: String
    let data: User
}

extension APIClient {
    func getUserInfo() async throws -> User {
        let response: GetUserInfoRes = try await get("/v1/user")
        return response.data
    }
}
