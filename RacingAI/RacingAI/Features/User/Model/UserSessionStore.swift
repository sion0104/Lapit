import Foundation

@MainActor
final class UserSessionStore: ObservableObject {
    @Published private(set) var user: User? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let signInAPI: SignInAPIProtocol = SignInAPI()
    
    var isLoggedIn: Bool { user != nil }
    
    func fetchUserIfNeeded() async {
        guard user == nil else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let user = try await APIClient.shared.getUserInfo()
            self.user = user
        } catch {
            self.user = nil
            errorMessage = describeAPIError(error)
        }
    }
    
    func logout() {
        TokenStore.shared.clear()
        user = nil
        errorMessage = nil
    }
    
    func withdraw() async throws {
        try await APIClient.shared.deleteUser()
        logout()
    }
    
    func login(username: String, password: String) async throws {
        let response = try await signInAPI.signIn(
            param: SignInReq(username: username, password: password)
        )
        
        let token = response.data
        
        TokenStore.shared.save(
            grantType: token.grantType,
            accessToken: token.accessToken,
            refreshToken: token.refreshToken
        )
        
        let user = try await APIClient.shared.getUserInfo()
        self.user = user
    }
}
