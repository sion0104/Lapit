import SwiftUI

struct CyclingDashboardView: View {
    @EnvironmentObject private var userSession: UserSessionStore
    
    @ObservedObject var rideVM: CyclingRideViewModel
        
    @State private var state: CyclingDashboardState = MockCyclingDashboardState.loggedIn // MockData
    
    @State private var showLogin: Bool = false
    @State private var showSettings: Bool = false
    
    @State private var isSessionActive: Bool = false
    @State private var isStopping: Bool = false
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var receiver = PhoneWorkoutReceiver.shared
    @StateObject private var live = CyclingDashboardLiveState()
    @StateObject private var recorder = WorkoutUploadRecorder()
    
    private var distanceText: String {
        MetricFormatter.metersToKmText(live.currentDistanceMeters)
    }

    private var speedText: String {
        MetricFormatter.speedMpsToKmhText(live.currentSpeedMps)
    }

    private var caloriesText: String {
        MetricFormatter.kcalText(live.currentCaloriesKcal)
    }

    private var currentBPM: Int {
        live.currentBPM
    }
    
    private var needsLogin: Bool { !userSession.isLoggedIn }
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    CDHeaderBar(
                        onProfileTap: {
                            if needsLogin {
                                showLogin = true
                            } else {
                                showSettings = true
                            }
                        }, onSettingsTap: {
                            showSettings = true
                        }
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
                                    rideVM.togglePauseResume()
                                    switch rideVM.status {
                                    case .paused:
                                        receiver.sendCommand(.pause)
                                    case .running:
                                        receiver.sendCommand(.resume)
                                    default:
                                        break
                                    }
                                },
                                onStop: {
                                    let finalDuration = rideVM.elapsedSeconds

                                    isStopping = true
                                    isSessionActive = false

                                    rideVM.stopWorkout()
                                    receiver.sendCommand(.stop)

                                    Task { @MainActor in
                                        do {
                                            try await recorder.stopAndUpload(
                                                workoutType: "cycling",
                                                durationSec: max(1, finalDuration),
                                                latestProvider: { receiver.latest }
                                            )
                                            rideVM.stopWorkout()
                                        } catch {
                                            print("❌ upload failed:", describeAPIError(error))
                                        }
                                        isStopping = false
                                    }
                                },
                                onCancelCountdown: { rideVM.cancelCountdown() }
                            )
                            
                            CDMetricGrid(
                                distanceText: distanceText,
                                distanceHint: "",
                                speedText: speedText,
                                paceHint: "",
                                currentBPM: currentBPM,
                                previousBPM: live.previousBPM,
                                previousLabel: live.previousLabel,
                                bpmDeltaText: live.bpmDeltaText,
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
                                    colors: [
                                        Color("MainCD"),
                                        Color(.white)
                                    ],
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
            NavigationStack {
                LoginView()
            }
        }
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
        .task {
            await userSession.fetchUserIfNeeded()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                rideVM.handleScenePhaseChange(.active)
                Task { await userSession.fetchUserIfNeeded()}
            case .inactive:
                rideVM.handleScenePhaseChange(.inactive)
            case .background:
                rideVM.handleScenePhaseChange(.background)
            @unknown default:
                break
            }
        }
        .onReceive(receiver.$latest.compactMap { $0 }) { payload in
            guard isSessionActive, !isStopping else { return }

            live.update(with: payload)
            recorder.append(payload)
        }
        .onAppear {
            rideVM.onRunningStarted = { [weak receiver] in
                isSessionActive = true
                isStopping = false

                recorder.start()
                receiver?.sendCommand(.startCycling)
            }
        }

    }
}

