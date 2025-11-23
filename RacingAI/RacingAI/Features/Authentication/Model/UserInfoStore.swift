import Foundation

final class UserInfoStore: ObservableObject {
    @Published var id: String = ""
    @Published var password: String = ""
    @Published var profileImageData: Data? = nil
    @Published var name: String = ""
    @Published var birth: String = ""
    @Published var gender: InformationView.Gender? = nil
}
