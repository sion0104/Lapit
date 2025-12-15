import Foundation

struct GetTermsListRes: Decodable, Identifiable {
    let id: Int
    let type: String
    let version: Double
    let required: Bool
    let title: String
    let content: String
    let useYn: Bool
    let sort: Int
    let effectiveDate: String
}

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
        let response: CommonResponse<[GetTermsListRes]> = try await client.get(path)
        return response.data
    }
}

