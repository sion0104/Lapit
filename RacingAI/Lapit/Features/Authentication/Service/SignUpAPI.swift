import Foundation

struct SignUpReq: Encodable {
    let username: String
    let password: String
    let name: String
    let birthDate: String?
    let gender: String?
    let agreeYn: String
    let termsList: [SignUpTerms]
}

struct SignUpTerms: Encodable {
    let termsId: Int64
    let agreeYn: String
}


struct SignUpRes: Decodable {
    let userId: Int64
}

protocol SignUpAPIProtocol {
    func signUp(param: SignUpReq, profileImageData: Data?) async throws -> CommonResponse<SignUpRes>
}

struct SignUpAPI: SignUpAPIProtocol {
    private let client: APIClient
    
    init(client: APIClient = .shared) {
        self.client = client
    }
    
    func signUp(param: SignUpReq, profileImageData: Data?) async throws -> CommonResponse<SignUpRes> {
        return try await client.postMultipartWithParam(
            "/v1/auth/sign-up",
            param: param,
            profileImageData: profileImageData
        )
    }
}
