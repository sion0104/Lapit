import Foundation

struct CommonResponseListGetTermsListRes: Decodable {
    let status: String        // "200"
    let message: String       // "요청에 성공하였습니다."
    let data: [GetTermsListRes]
}

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
