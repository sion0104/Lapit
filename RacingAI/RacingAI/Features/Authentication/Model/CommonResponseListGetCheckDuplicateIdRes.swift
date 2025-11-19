import Foundation

struct CommonResponseListGetCheckDuplicateIdRes: Decodable {
    let status: String
    let message: String       
    let data: [String: String?]
}
