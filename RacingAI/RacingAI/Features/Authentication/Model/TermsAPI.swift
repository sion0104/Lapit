import Foundation

protocol TermsAPIProtocol {
    func fetchTerms() async throws -> [GetTermsListRes]
}

struct TermsAPI: TermsAPIProtocol {

    private let client: APIClient

    init(client: APIClient = .shared) {
        self.client = client
    }

    func fetchTerms() async throws -> [GetTermsListRes] {
        let path = "/v1/auth/terms"
        let response: CommonResponseListGetTermsListRes = try await client.get(path)
        return response.data
    }
}

