import Foundation

final class UserInfoStore: ObservableObject {
    @Published var id: String = ""
    @Published var password: String = ""
    @Published var profileImageData: Data? = nil
    @Published var name: String = ""
    @Published var birth: String = ""
    @Published var gender: InformationView.Gender? = nil
    @Published var agreedTerms: [Int: Bool] = [:]
    
    func isAgreed(termId: Int) -> Bool {
        agreedTerms[termId] ?? false
    }
    
    func setAgreed(termId: Int, isOn: Bool) {
        agreedTerms[termId] = isOn
    }
    
    func areAllRequiredAgreed(requiredTermIds: [Int]) -> Bool {
        requiredTermIds.allSatisfy { agreedTerms[$0] == true }
    }
}
