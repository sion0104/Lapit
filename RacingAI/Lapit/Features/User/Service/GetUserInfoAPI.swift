import Foundation

protocol GetUserInfoAPIProtocol {
    func getUserInfo() async throws -> User
}

struct GetUserInfoAPI: GetUserInfoAPIProtocol {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func getUserInfo() async throws -> User {
        let response: CommonResponse<User> = try await client.get("/v1/user")
        return response.data
    }
}
