import Foundation

protocol CheckDuplicateIdAPIProtocol {
    func fetchCheckDuplicateID(username: String) async throws -> Bool
}

struct CheckDuplicateIDAPI: CheckDuplicateIdAPIProtocol {

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchCheckDuplicateID(username: String) async throws -> Bool {
        let encoded = username.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? username
        let path = "/v1/auth/check-id?username=\(encoded)"
        
        do {
            let _: CommonResponseNoData = try await client.get(path)
            return true
        } catch let APIError.serverStatusCode(status, _) {
            print("[CheckDuplicatedIDAPI] 중복 아이디: \(status)")
            return false
        } catch {
            throw error
        }
    }
}
