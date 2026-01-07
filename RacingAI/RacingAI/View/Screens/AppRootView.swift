import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var userSession: UserSessionStore
    @EnvironmentObject private var userInfoStore: UserInfoStore
    
    var body: some View {
        Group {
            if !userSession.didRestoreSession {
                HomeView()
            } else if userSession.isLoggedIn {
                TabContainerView()
            } else {
                AuthEntryView()
            }
        }
        .task {
            await userSession.restoreSessionIfNeeded()
        }
    }
}

#Preview {
    AppRootView()
        .environmentObject(UserSessionStore())
        .environmentObject(UserInfoStore())
}
