import Foundation

struct ModifyUserInfoReq: Encodable {
    let name: String
    let birthDate: String?
    let gender: String?
}

protocol ModifyUserInfoAPIProtocol {
    func modifyUser(param: ModifyUserInfoReq, profileImageData: Data?) async throws
}

struct ModifyUserInfoAPI: ModifyUserInfoAPIProtocol {
    private let client: APIClient
    
    init(client: APIClient = .shared) {
        self.client = client
    }
    
    func modifyUser(param: ModifyUserInfoReq, profileImageData: Data?) async throws {
        try await client.putMultiPartWithParamVoid(
            "/v1/user",
            param: param,
            profileImageData: profileImageData
        )
    }
}
