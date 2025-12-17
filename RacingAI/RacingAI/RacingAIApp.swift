import SwiftUI

@main
struct RacingAIApp: App {
    @StateObject private var userInfoStore = UserInfoStore()
    @StateObject private var bodyInfoStore = BodyInfoStore()
    @StateObject private var userSessionStore = UserSessionStore()

    
    var body: some Scene {
        WindowGroup {
            AuthenticationView()
                .environmentObject(userInfoStore)
                .environmentObject(bodyInfoStore)
//            MypageSettingView()
//                .environmentObject(userSessionStore)
        }
    }
}
