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

extension UserInfoStore {
    func makeSignUpRequ(
        terms: [GetTermsListRes]
    ) -> SignUpReq? {
        guard
            !id.isEmpty,
            !password.isEmpty,
            !name.isEmpty,
            !birth.isEmpty,
            let gender
        else {
            return nil
        }
        
        let birthForAPI = birth.replacingOccurrences(of: ".", with: "-")
        
        let genderCode: String
        switch gender {
        case .male: genderCode = "M"
        case .female: genderCode = "F"
        }
        
        let termsList: [SignUpTerms] = terms.map { term in
            SignUpTerms(
                termsId: Int64(term.id),
                agreeYn: (agreedTerms[term.id] == true ? "Y": "N")
            )
        }
        
        return SignUpReq(
            username: id,
            password: password,
            name: name,
            birthDate: birthForAPI,
            gender: genderCode,
            agreeYn: "Y",
            termsList: termsList
        )
    }
}

