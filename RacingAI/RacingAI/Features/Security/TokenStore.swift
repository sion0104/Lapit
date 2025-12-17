import Foundation

final class TokenStore {
    static let shared = TokenStore()
    private init() {}

    private enum Key {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let grantType = "grantType"
    }

    func save(grantType: String, accessToken: String, refreshToken: String) {
        UserDefaults.standard.set(accessToken, forKey: Key.accessToken)
        UserDefaults.standard.set(refreshToken, forKey: Key.refreshToken)
        UserDefaults.standard.set(grantType, forKey: Key.grantType)
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
        guard
            let accessToken = loadAccessToken(),
            !accessToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return nil
        }

        let grantType = UserDefaults.standard.string(forKey: Key.grantType) ?? "Bearer"
        return "\(grantType) \(accessToken)"
    }
}

extension TokenStore {
    func debugPrintTokenStatus(context: String = "") {
        let access = loadAccessToken()
        let refresh = loadRefreshToken()

        print("🧪 [TokenStore DEBUG] \(context)")
        print("  - accessToken:", access == nil ? "nil" : "exists (\(access!.count) chars)")
        print("  - refreshToken:", refresh == nil ? "nil" : "exists (\(refresh!.count) chars)")
    }
}

