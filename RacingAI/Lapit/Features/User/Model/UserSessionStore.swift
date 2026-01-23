import Foundation

@MainActor
final class UserSessionStore: ObservableObject {
    @Published private(set) var user: User? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published private(set) var didRestoreSession: Bool = false

    private let signInAPI: SignInAPIProtocol = SignInAPI()

    var isLoggedIn: Bool { user != nil }

    func fetchUser() async throws {
        let user = try await APIClient.shared.getUserInfo()
        self.user = user
    }

    /// 앱 시작 시 자동 로그인 복원
    func restoreSessionIfNeeded() async {
        errorMessage = nil
        isLoading = true
        defer {
            isLoading = false
            didRestoreSession = true
        }

        // refreshToken이 있으면 먼저 refresh로 access 확보(또는 API 호출해서 401이면 자동 refresh 되게 해도 됨)
        if TokenStore.shared.loadRefreshToken() != nil {
            do {
                // 1) refresh 시도 (access 만료 여부 관계없이, 복원 시엔 한번 해주는 게 UX 좋음)
                try await TokenRefresher.shared.refreshIfPossible()

                // 2) 유저 로딩
                try await fetchUser()
                return
            } catch {
                // refresh 실패하면 토큰 제거 후 로그인 화면 유도
                TokenStore.shared.clear()
                self.user = nil
                self.errorMessage = describeAPIError(error)
                return
            }
        }

        // refreshToken이 없으면 로그인 상태 아님
        self.user = nil
    }

    func login(username: String, password: String) async throws {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        let response = try await signInAPI.signIn(
            param: SignInReq(username: username, password: password)
        )

        let token = response.data
        TokenStore.shared.save(
            grantType: token.grantType,
            accessToken: token.accessToken,
            refreshToken: token.refreshToken
        )

        try await fetchUser()
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

    func refreshUser() async throws {
        try await fetchUser()
    }
}
