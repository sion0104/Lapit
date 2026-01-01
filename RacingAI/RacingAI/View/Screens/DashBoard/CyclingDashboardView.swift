import SwiftUI

struct CyclingDashboardView: View {
    @EnvironmentObject private var userSession: UserSessionStore
        
    @State private var state: CyclingDashboardState = MockCyclingDashboardState.loggedIn // MockData
    
    @State private var showLogin: Bool = false
    @State private var showSettings: Bool = false
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var rideVM = CyclingRideViewModel()
    
    @StateObject private var receiver = PhoneWorkoutReceiver.shared
    @StateObject private var live = CyclingDashboardLiveState()
    
    private var distanceText: String {
        MetricFormatter.metersToKmText(receiver.latest?.distanceMeters)
    }

    private var speedText: String {
        MetricFormatter.speedMpsToKmhText(receiver.latest?.speedMps)
    }

    private var caloriesText: String {
        MetricFormatter.kcalText(receiver.latest?.activeEnergyKcal)
    }

    private var currentBPM: Int {
        MetricFormatter.bpmInt(receiver.latest?.heartRateBPM)
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
                                    rideVM.stopWorkout()
                                    receiver.sendCommand(.stop)
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
                                previousLabel: "",
                                bpmDeltaText: "",
                                caloriesText: caloriesText
                            )
                            
                            Divider()
                                .foregroundStyle(.circle)
                            
                            Button {
                                guard !needsLogin else { showLogin = true; return}
                            } label: {
                                Text("자세히 보기")
                                    .font(.caption)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 5)
                                    .foregroundColor(.secondaryFont)
                            }
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
                    
                    CDStatusSection(
                        conditionTitle: state.conditionTitle,
                        conditionLevelText: state.conditionLevelText,
                        conditionDesc: state.conditionDesc,
                        scoreTitle: state.exerciseScoreTitle,
                        scoreLabel: state.exerciseScoreLabel,
                        scoreValue: state.exerciseScoreValue,
                        scoreDesc: state.exerciseScoreDesc,
                        avgTitle: state.avgExerciseTitle,
                        avgTimeText: state.avgExerciseTimeText,
                        avgDesc: state.avgExerciseDesc
                    )
                    .padding(.top, 15)
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
        .navigationDestination(isPresented: $showSettings, destination: {
            MypageSettingView()
        })
        .sheet(isPresented: $showLogin) {
            // UI만: 임시 로그인 시트
            VStack(spacing: 16) {
                Text("로그인 화면(임시)")
                    .font(.title2.weight(.bold))
            
                Button("로그인 성공(목데이터)") {
                    showLogin = false
                }
                .buttonStyle(.borderedProminent)
                
                Button("닫기") {
                    showLogin = false
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .presentationDetents([.medium])
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
        .onReceive(receiver.$latest.compactMap { $0 }) { live.update(with: $0) }
        .onAppear {
            rideVM.onRunningStarted = { [weak receiver = receiver] in
                receiver?.sendCommand(.startCycling)
            }
        }
    }
    
    
}

#Preview {
    CyclingDashboardView()
        .environmentObject(UserSessionStore())
}
