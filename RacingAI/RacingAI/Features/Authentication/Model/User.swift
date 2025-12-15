import Foundation

struct User: Decodable, Identifiable {
    let id: Int
    let username: String
    let name: String
    let profileImgUrl: String?
}
