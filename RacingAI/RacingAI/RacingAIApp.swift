import SwiftUI

@main
struct RacingAIApp: App {
    @StateObject private var store = UserInfoStore()
    
    var body: some Scene {
        WindowGroup {
            AuthenticationView()
                .environmentObject(store)
        }
    }
}
