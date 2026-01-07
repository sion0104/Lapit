import Foundation

protocol CheckPasswordAPIProtocol {
    func checkPassword(password: String) async throws
}

struct CheckPasswordAPI: CheckPasswordAPIProtocol {
    private let client: APIClient
    
    init(client: APIClient = .shared) {
        self.client = client
    }
    
    func checkPassword(password: String) async throws {
        let trimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        try await client.getVoidWithQuery(
            "/v1/user/check-password",
            queryItems: [
                URLQueryItem(name: "password", value: trimmed)
            ]
        )
    }
}
