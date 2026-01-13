import Foundation

struct User: Decodable, Identifiable {
    let id: Int
    let username: String // userId
    let name: String
    let birthDate: String

    let height: Double?
    let weight: Double?
    let bmi: Double?

    let agreeYn: String
    let gender: String
    let profileImgUrl: String?
}
