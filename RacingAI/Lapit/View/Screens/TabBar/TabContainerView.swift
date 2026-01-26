import SwiftUI

struct TabContainerView: View {
    @StateObject private var router = TabRouter()
    
    @StateObject private var rideVM = CyclingRideViewModel()
    @StateObject private var workoutDailyStore = WorkoutDailyStore()
    
    private let tabBarContentHeight: CGFloat = 62

    var body: some View {
        GeometryReader { proxy in
            let tabBarTotalHeight = router.isTabBarHidden ? 0 : tabBarContentHeight

            ZStack(alignment: .bottom) {
                Group {
                    switch router.selection {
                    case .exercise:
                        CyclingDashboardView(rideVM: rideVM)
                            .environmentObject(router)

                    case .planner:
                        WorkoutDashboardLikeView()
                            .environmentObject(workoutDailyStore)
                            .environmentObject(router)

                    case .aiCoach:
                        AICoachView(onBack: {})
                            .environmentObject(router)

                    case .settings:
                        MypageSettingView()
                            .environmentObject(router)
                    }
                }
                .safeAreaPadding(.bottom, tabBarTotalHeight)
                .onPreferenceChange(TabBarHiddenPreferenceKey.self) { hidden in
                    Task { @MainActor in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            router.isTabBarHidden = hidden
                        }
                    }
                }

                if !router.isTabBarHidden {
                    CustomTabBarView(tabs: AppTab.allCases, selection: $router.selection)
                        .frame(height: tabBarContentHeight)
                }
            }
            .task {
                workoutDailyStore.preloadTodayIfNeeded()
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}
