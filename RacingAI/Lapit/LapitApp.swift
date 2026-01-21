import SwiftUI

@main
struct LapitApp: App {
    @StateObject private var userInfoStore = UserInfoStore()
    @StateObject private var bodyInfoStore = BodyInfoStore()
    @StateObject private var userSessionStore = UserSessionStore()

    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(userInfoStore)
                .environmentObject(bodyInfoStore)
                .environmentObject(userSessionStore)
        }
        .modelContainer(
            for: [
                DailyPlanEntity.self
            ]
        )
    }
}
