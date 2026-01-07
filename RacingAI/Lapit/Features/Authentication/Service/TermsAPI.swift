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

struct GetTermRes: Decodable {
    let id: Int
    let title: String
    let content: String
}

protocol TermsAPIProtocol {
    func fetchTerms() async throws -> [GetTermsListRes]
    func fetchTerm(termsId: Int64) async throws -> GetTermRes
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
    
    func fetchTerm(termsId: Int64) async throws -> GetTermRes {
        let path = "/v1/auth/terms/\(termsId)"
        let response: CommonResponse<GetTermRes> = try await client.get(path)
        return response.data
    }
}

