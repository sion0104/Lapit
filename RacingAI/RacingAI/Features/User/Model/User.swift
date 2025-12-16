import Foundation

struct User: Decodable, Identifiable {
    let id: String
    let name: String
    let birthDate: String
    let gender: String
    let profileImgUrl: String?
}
