import Foundation

final class TokenStore {
    static let shared = TokenStore()
    private init() {}
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    func save(grantType: String, accessToken: String, refreshToken: String) {
        UserDefaults.standard.set(grantType, forKey: "grantType")
        UserDefaults.standard.set(accessToken, forKey: "accessToken")
        UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
    }
    
    func loadAccessToken() -> String? {
        UserDefaults.standard.string(forKey: accessTokenKey)
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
    }
    
    func loadAuthorizationValue() -> String? {
        guard
            let grantType = UserDefaults.standard.string(forKey: "grantType"),
            let accessToken = UserDefaults.standard.string(forKey: "accessToken"),
            !accessToken.isEmpty
        else { return nil }

        return "\(grantType) \(accessToken)"
    }
}
