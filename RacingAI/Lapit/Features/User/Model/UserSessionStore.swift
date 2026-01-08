import Foundation

@MainActor
final class UserSessionStore: ObservableObject {
    @Published private(set) var user: User? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @Published private(set) var didRestoreSession: Bool = false
    
    private let signInAPI: SignInAPIProtocol = SignInAPI()
    
    var isLoggedIn: Bool { user != nil }
    
    func fetchUserIfNeeded() async {
        guard TokenStore.shared.loadAccessToken() != nil else {
            self.user = nil
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await APIClient.shared.getUserInfo()
            self.user = user
        } catch {
            self.errorMessage = describeAPIError(error)
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
            grantType: token.grantType, accessToken: token.accessToken,
            refreshToken: token.refreshToken
        )
        
        let user = try await APIClient.shared.getUserInfo()
        self.user = user
    }
    
    @MainActor
    func refreshUser() async throws {
        let user = try await APIClient.shared.getUserInfo()
        self.user = user
    }
}

extension UserSessionStore {
    func restoreSessionIfNeeded() async {
        await fetchUserIfNeeded()
        didRestoreSession = true
    }
}
