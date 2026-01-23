import Foundation

struct RefreshRes: Decodable {
    let grantType: String
    let accessToken: String
    let refreshToken: String
}

protocol RefreshAPIProtocol {
    func refresh(refreshToken: String) async throws -> CommonResponse<RefreshRes>
}

struct RefreshAPI: RefreshAPIProtocol {
    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func refresh(refreshToken: String) async throws -> CommonResponse<RefreshRes> {
        let items = [
            URLQueryItem(name: "refreshToken", value: refreshToken)
        ]
        return try await client.postWithQuery(
            "/v1/auth/refresh",
            queryItems: items,
            attachAuth: false
        )
    }
}
