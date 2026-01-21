import SwiftUI

struct CyclingDashboardView: View {
    @EnvironmentObject private var userSession: UserSessionStore

    @ObservedObject var rideVM: CyclingRideViewModel

    @State private var showLogin: Bool = false
    @State private var showSettings: Bool = false

    @State private var isSessionActive: Bool = false
    @State private var isStopping: Bool = false
    
    @State private var hideStatusTask: Task<Void, Never>?

    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var receiver = PhoneWorkoutReceiver.shared
    @StateObject private var live = CyclingDashboardLiveState()
    @StateObject private var recorder = WorkoutUploadRecorder()
    
    
    
    private func compactStatusText(_ s: PhoneWorkoutReceiver.DeliveryState) -> String {
        switch s {
        case .idle:
            return ""
        case .waitingForWatch:
            return "워치 연결 대기"
        case .sending(let cmd, let attempt):
            // attempt는 너무 길면 빼도 됨. 우선 최소로만 표시
            return "\(cmd.rawValue) 전송 중(\(attempt))"
        case .acked(let ack):
            return "워치: \(ackStatusKorean(ack.status.rawValue))"
        case .failed:
            return "전송 실패"
        }
    }
    
    private func ackStatusKorean(_ raw: String) -> String {
        switch raw {
        case "received": return "수신됨"
        case "started": return "시작됨"
        case "paused": return "일시정지"
        case "resumed": return "재개"
        case "stopped": return "종료"
        case "failed": return "실패"
        default: return raw
        }
    }

    private var distanceText: String { MetricFormatter.metersToKmText(live.currentDistanceMeters) }
    private var speedText: String { MetricFormatter.speedMpsToKmhText(live.currentSpeedMps) }
    private var caloriesText: String { MetricFormatter.kcalText(live.currentCaloriesKcal) }
    private var currentBPM: Int { live.currentBPM }

    private var needsLogin: Bool { !userSession.isLoggedIn }

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    CDHeaderBar(
                        onProfileTap: {
                            if needsLogin { showLogin = true }
                            else { showSettings = true }
                        },
                        onSettingsTap: { showSettings = true }
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
                                    // ✅ 토글하기 전에 "현재 상태"를 캡처해서 명령을 결정해야 함
                                    let before = rideVM.status

                                    rideVM.togglePauseResume()

                                    switch before {
                                    case .running:
                                        receiver.sendEventually(.pause)
                                    case .paused:
                                        receiver.sendEventually(.resume)
                                    default:
                                        break
                                    }
                                },
                                onStop: {
                                    let finalDuration = rideVM.elapsedSeconds

                                    isStopping = true
                                    isSessionActive = false

                                    // ✅ UI 타이머는 즉시 종료
                                    rideVM.stopWorkout()

                                    // ✅ 워치 stop도 eventually 보장
                                    receiver.sendEventually(.stop)

                                    Task { @MainActor in
                                        do {
                                            try await recorder.stopAndUpload(
                                                workoutType: "cycling",
                                                durationSec: max(1, finalDuration),
                                                latestProvider: { receiver.latest }
                                            )
                                        } catch {
                                            print("❌ upload failed:", describeAPIError(error))
                                        }
                                        isStopping = false
                                    }
                                },
                                onCancelCountdown: {
                                    rideVM.cancelCountdown()
                                }
                            )
                            
                            let compact = compactStatusText(receiver.deliveryState)
                            if !compact.isEmpty {
                                WatchDeliveryPill(text: compact)
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

        // ⚠️ showLogin cover가 중복으로 3번 걸려있었음(fullScreenCover 2 + sheet 1)
        // 하나만 남기는 게 정상입니다. 아래는 fullScreenCover 하나만 유지하는 예시:
        .fullScreenCover(isPresented: $showLogin) {
            NavigationStack { LoginView() }
        }

        .task {
            await userSession.fetchUserIfNeeded()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                rideVM.handleScenePhaseChange(.active)
                Task { await userSession.fetchUserIfNeeded() }
            case .inactive:
                rideVM.handleScenePhaseChange(.inactive)
            case .background:
                rideVM.handleScenePhaseChange(.background)
            @unknown default:
                break
            }
        }
        .onChange(of: receiver.deliveryState) { _, newValue in
            hideStatusTask?.cancel()

            switch newValue {
            case .acked(let ack):
                // started/paused/resumed/stopped/fail 등 원하는 기준에 맞춰
                hideStatusTask = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    // receiver 내부 state를 바꾸는 건 private(set)이라 직접 불가.
                    // 대신 UI에서 표시용 텍스트를 별도 @State로 관리하는게 제일 깔끔함.
                }
            case .failed:
                hideStatusTask = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                }
            default:
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

                // ✅ start도 eventually 보장
                receiver?.sendEventually(.startCycling)
            }
        }
    }
}
