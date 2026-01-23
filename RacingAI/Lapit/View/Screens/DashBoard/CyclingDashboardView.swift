import SwiftUI

struct CyclingDashboardView: View {
    @EnvironmentObject private var userSession: UserSessionStore

    @ObservedObject var rideVM: CyclingRideViewModel

    @State private var showLogin: Bool = false
    @State private var showSettings: Bool = false
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var store = CyclingDashboardStore.shared
    @StateObject private var receiver = PhoneWorkoutReceiver.shared

    private var distanceText: String { MetricFormatter.metersToKmText(store.live.currentDistanceMeters) }
    private var speedText: String { MetricFormatter.speedMpsToKmhText(store.live.currentSpeedMps) }
    private var caloriesText: String { MetricFormatter.kcalText(store.live.currentCaloriesKcal) }
    private var currentBPM: Int { store.live.currentBPM }

    private var needsLogin: Bool { !userSession.isLoggedIn }

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    CDHeaderBar(
                        onProfileTap: {},
                        onSettingsTap: {}
                    )

                    VStack {
                        CDCard {
                            CDDateWeatherBarView()

                            CDSessionHeroCard(
                                durationText: rideVM.duration,
                                status: rideVM.status,
                                onStart: {
                                    rideVM.startWith3SecDelay()
                                },
                                onPauseResume: {
                                    let before = rideVM.status
                                    rideVM.togglePauseResume()
                                    store.pauseOrResume(currentStatus: before)
                                },
                                onStop: {
                                    let finalDuration = rideVM.elapsedSeconds
                                    rideVM.stopWorkout()

                                    Task { @MainActor in
                                        await store.stopAndUpload(
                                            durationSec: finalDuration,
                                            latestProvider: { receiver.latest }
                                        )
                                    }
                                },
                                onCancelCountdown: {
                                    rideVM.cancelCountdown()
                                }
                            )
                            
                            if !store.statusText.isEmpty {
                                WatchDeliveryPill(text: store.statusText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 20)
                                    .padding(.top, -10)
                                    .padding(.bottom, 6)
                            }

                            CDMetricGrid(
                                distanceText: distanceText,
                                distanceHint: "",
                                speedText: speedText,
                                paceHint: "",
                                currentBPM: currentBPM,
                                previousBPM: store.live.previousBPM,
                                previousLabel: store.live.previousLabel,
                                bpmDeltaText: store.live.bpmDeltaText,
                                caloriesText: caloriesText
                            )
                        }
                        .fullScreenCover(isPresented: $showLogin) {
                            NavigationStack {
                                LoginView()
                                    .tabBarHidden(true)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color("MainCD"), Color(.white)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .shadow(color: .shadow, radius: 4, x: 0, y: -2)
                }
                .padding()
            }
        }
        .background(Color("HomeBackground"))
        .fullScreenCover(isPresented: $showLogin) {
            NavigationStack { LoginView() }
        }

        .task {
            guard userSession.isLoggedIn else { return }
            try? await userSession.refreshUser()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                rideVM.handleScenePhaseChange(.active)
                Task {
                    guard userSession.isLoggedIn else { return }
                    try? await userSession.refreshUser()
                }
            case .inactive:
                rideVM.handleScenePhaseChange(.inactive)
            case .background:
                rideVM.handleScenePhaseChange(.background)
            @unknown default:
                break
            }
        }
        .onReceive(receiver.$latest.compactMap { $0 }) { payload in
            store.handleIncomingPayload(payload)
        }
        .onAppear {
            rideVM.onRunningStarted = {
                store.startSession()
            }
        }
        .alert("연결 끊김", isPresented: $store.showReconnectAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(store.reconnectMessage)
        }
    }
}
