import Foundation

final class TokenStore {
    static let shared = TokenStore()
    private init() {}

    private enum Key {
        static let accessToken = "accessToken"
        static let grantType = "grantType"

        // Keychain keys
        static let refreshToken = "refreshToken"
    }

    private let keychain = KeychainStore.shared

    func save(grantType: String, accessToken: String, refreshToken: String) {
        UserDefaults.standard.set(accessToken, forKey: Key.accessToken)
        UserDefaults.standard.set(grantType, forKey: Key.grantType)

        do {
            try keychain.set(refreshToken, forKey: Key.refreshToken)
        } catch {
            // Keychain 저장 실패는 치명적이니 로그 남기고 필요시 앱 정책에 따라 처리
            print("❗️Keychain save failed:", error)
        }
    }

    func loadAccessToken() -> String? {
        UserDefaults.standard.string(forKey: Key.accessToken)
    }

    func loadRefreshToken() -> String? {
        do {
            return try keychain.get(Key.refreshToken)
        } catch {
            print("❗️Keychain read failed:", error)
            return nil
        }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: Key.accessToken)
        UserDefaults.standard.removeObject(forKey: Key.grantType)

        do {
            try keychain.remove(Key.refreshToken)
        } catch {
            print("❗️Keychain remove failed:", error)
        }
    }

    func loadAuthorizationValue() -> String? {
        guard
            let accessToken = loadAccessToken(),
            !accessToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return nil }

        let grantType = UserDefaults.standard.string(forKey: Key.grantType) ?? "Bearer"
        return "\(grantType) \(accessToken)"
    }
}
