import Foundation

@MainActor
final class CyclingDashboardStore: ObservableObject {
    static let shared = CyclingDashboardStore()

    @Published var isSessionActive: Bool = false
    @Published var isStopping: Bool = false

    @Published var statusText: String = ""

    @Published var live = CyclingDashboardLiveState()
    @Published var recorder = WorkoutUploadRecorder()
    
    @Published var showReconnectAlert: Bool = false
    @Published var reconnectMessage: String = ""

    private let receiver = PhoneWorkoutReceiver.shared

    private var lastPayloadAt: Date?
    private var monitorTask: Task<Void, Never>?

    var disconnectSec: TimeInterval = 4.0

    private init() {
        startMonitor()
    }

    func startSession() {
        isSessionActive = true
        isStopping = false
        lastPayloadAt = nil

        live.reset()
        recorder.start()

        statusText = "운동 데이터 연동 중"

        receiver.sendEventually(.startCycling)
    }

    func pauseOrResume(currentStatus: CyclingRideViewModel.RideStatus) {
        switch currentStatus {
        case .running:
            receiver.sendEventually(.pause)
            statusText = "운동 데이터 연동 중"
        case .paused:
            receiver.sendEventually(.resume)
            statusText = "운동 데이터 연동 중"
        default:
            break
        }
    }

    func stopAndUpload(durationSec: Int, latestProvider: @escaping () -> LiveMetricsPayload?) async {
        isStopping = true
        isSessionActive = false

        receiver.sendEventually(.stop)

        do {
            try await recorder.stopAndUpload(
                workoutType: "cycling",
                durationSec: max(1, durationSec),
                latestProvider: latestProvider
            )
        } catch {
            print("❌ upload failed:", error)
        }

        statusText = ""
        live.reset()
        isStopping = false
    }

    func handleIncomingPayload(_ payload: LiveMetricsPayload) {
        guard isSessionActive, !isStopping else { return }

        lastPayloadAt = Date()
        live.update(with: payload)
        recorder.append(payload)

        statusText = "운동 데이터 연동 중"
    }

    private func startMonitor() {
        monitorTask?.cancel()
        monitorTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                self.tickMonitor()
            }
        }
    }

    private func tickMonitor() {
        guard isSessionActive, !isStopping else { return }
        guard let last = lastPayloadAt else { return }

        if Date().timeIntervalSince(last) > disconnectSec {
            statusText = ""
            live.reset()
            isSessionActive = false

            reconnectMessage = "애플 워치와 연결이 끊겼어요.\n워치에서 앱을 열고 다시 시작해 주세요."
            showReconnectAlert = true
        }
    }
}
