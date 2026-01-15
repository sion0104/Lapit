import SwiftUI

struct TabContainerView: View {
    @State private var selection: AppTab = .exercise
    @State private var isTabBarHidden: Bool = false
    
    @StateObject private var rideVM = CyclingRideViewModel()
    @StateObject private var workoutDailyStore = WorkoutDailyStore()
    
    private let tabBarContentHeight: CGFloat = 62

    var body: some View {
        GeometryReader { proxy in
            let tabBarTotalHeight = isTabBarHidden ? 0 : tabBarContentHeight

            ZStack(alignment: .bottom) {
                Group {
                    switch selection {
                    case .exercise:
                        CyclingDashboardView(rideVM: rideVM)

                    case .planner:
                        WorkoutDashboardLikeView()
                            .environmentObject(workoutDailyStore)

                    case .aiCoach:
                        AICoachView(onBack: {})

                    case .settings:
                        MypageSettingView()
                    }
                }
                .safeAreaPadding(.bottom, tabBarTotalHeight)
                .onPreferenceChange(TabBarHiddenPreferenceKey.self) { hidden in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isTabBarHidden = hidden
                    }
                }

                if !isTabBarHidden {
                    CustomTabBarView(tabs: AppTab.allCases, selection: $selection)
                        .frame(height: tabBarContentHeight)
                }
            }
            .onAppear {
                workoutDailyStore.preloadTodayIfNeeded()
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}
