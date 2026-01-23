import Foundation

actor TokenRefresher {
    static let shared = TokenRefresher()

    private let refreshAPI: RefreshAPIProtocol
    private var inFlightTask: Task<Void, Error>? = nil

    init(refreshAPI: RefreshAPIProtocol = RefreshAPI()) {
        self.refreshAPI = refreshAPI
    }

    /// accessToken이 만료됐을 때 호출. 동시 호출되더라도 refresh는 1회만 실행됨.
    func refreshIfPossible() async throws {
        if let task = inFlightTask {
            return try await task.value
        }

        let task = Task<Void, Error> {
            defer { Task { await self.clearInFlight() } }

            guard let refresh = TokenStore.shared.loadRefreshToken(),
                  !refresh.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                throw AuthError.noRefreshToken
            }

            let res = try await refreshAPI.refresh(refreshToken: refresh)
            let token = res.data

            TokenStore.shared.save(
                grantType: token.grantType,
                accessToken: token.accessToken,
                refreshToken: token.refreshToken
            )
        }

        inFlightTask = task
        return try await task.value
    }

    private func clearInFlight() {
        inFlightTask = nil
    }
}

enum AuthError: Error {
    case noRefreshToken
}
