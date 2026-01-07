import SwiftUI

struct TabContainerView: View {
    @State private var selection: AppTab = .exercise
    @State private var isTabBarHidden: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selection {
                case .exercise:
                    CyclingDashboardView()
                case .planner:
                    EmptyView()
                case .aiCoach:
                    EmptyView()
                case .settings:
                    MypageSettingView()
                }
            }
            .onPreferenceChange(TabBarHiddenPreferenceKey.self) { hidden in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isTabBarHidden = hidden
                }
            }
            .safeAreaPadding(.bottom, isTabBarHidden ? 0 : 62)

            if !isTabBarHidden {
                CustomTabBarView(tabs: AppTab.allCases, selection: $selection)
                    .frame(height: 62)
                    .ignoresSafeArea(.container, edges: .bottom)
            }
        }
    }
}
