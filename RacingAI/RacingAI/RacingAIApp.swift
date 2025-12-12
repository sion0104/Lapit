import SwiftUI

@main
struct RacingAIApp: App {
    @StateObject private var userInfoStore = UserInfoStore()
    @StateObject private var bodyInfoStore = BodyInfoStore()

    
    var body: some Scene {
        WindowGroup {
            AuthenticationView()
                .environmentObject(userInfoStore)
        }
    }
}
