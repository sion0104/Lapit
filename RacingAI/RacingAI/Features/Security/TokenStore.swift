import Foundation

final class TokenStore {
    static let shared = TokenStore()
    private init() {}

    private enum Key {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }

    func save(accessToken: String, refreshToken: String) {
        UserDefaults.standard.set(accessToken, forKey: Key.accessToken)
        UserDefaults.standard.set(refreshToken, forKey: Key.refreshToken)
    }

    func loadAccessToken() -> String? {
        UserDefaults.standard.string(forKey: Key.accessToken)
    }

    func loadRefreshToken() -> String? {
        UserDefaults.standard.string(forKey: Key.refreshToken)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: Key.accessToken)
        UserDefaults.standard.removeObject(forKey: Key.refreshToken)
    }

    func loadAuthorizationValue() -> String? {
        guard let accessToken = loadAccessToken(), !accessToken.isEmpty else {
            return nil
        }
        return "Bearer \(accessToken)"
    }
}
