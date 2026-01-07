import Foundation

struct CommonResponse<Payload: Decodable>: Decodable {
    let status: String
    let message: String       
    let data: Payload
}

struct EmptyData: Decodable {}
