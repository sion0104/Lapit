import Foundation

struct SignUpReq: Encodable {
    let username: String
    let password: String
    let name: String
    let birthDate: String
    let gender: String
    let agreeYn: String
    let termsList: [SignUpTerms]
}

struct SignUpTerms: Encodable {
    let termsId: Int64
    let agreeYn: String
}

struct CommonResponseSignUpRes: Decodable {
    let status: String
    let message: String
    let data: SignUpRes
}

struct SignUpRes: Decodable {
    let userId: Int64
}

protocol SignUpAPIProtocol {
    func signUp(param: SignUpReq, profileImageData: Data?) async throws -> CommonResponseSignUpRes
}

struct SignUpAPI: SignUpAPIProtocol {
    private let client: APIClient
    
    init(client: APIClient = .shared) {
        self.client = client
    }
    
    func signUp(param: SignUpReq, profileImageData: Data?) async throws -> CommonResponseSignUpRes {
        return try await client.postMultipartWithParam(
            "/v1/auth/sign-up",
            param: param,
            profileImageData: profileImageData
        )
    }
}
