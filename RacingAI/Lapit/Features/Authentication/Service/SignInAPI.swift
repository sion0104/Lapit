import Foundation

struct SignInReq: Encodable {
    let username: String
    let password: String
}

struct SignInRes: Decodable {
    let grantType: String
    let accessToken: String
    let refreshToken: String
}

protocol SignInAPIProtocol {
    func signIn(param: SignInReq) async throws -> CommonResponse<SignInRes>
}

struct SignInAPI:SignInAPIProtocol {
    private let client: APIClient
    
    init(client: APIClient = .shared) {
        self.client = client
    }
    
    func signIn(param: SignInReq) async throws -> CommonResponse<SignInRes> {
        let username = param.username.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = param.password.trimmingCharacters(in: .whitespacesAndNewlines)

        return try await client.postForm(
            "/v1/auth/sign-in",
            form: [
                "username": username,
                "password": password
            ]
        )
    }
}


