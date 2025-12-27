import SwiftUI

@main
struct WatchApp: App {
    init() {
        _ = WatchCommandReceiver.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
