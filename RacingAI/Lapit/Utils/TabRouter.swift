import SwiftUI

@MainActor
final class TabRouter: ObservableObject {
    @Published var selection: AppTab = .exercise
    @Published var isTabBarHidden: Bool = false

    @Published var showLogin: Bool = false

    func goSettings() {
        selection = .settings
    }
}
