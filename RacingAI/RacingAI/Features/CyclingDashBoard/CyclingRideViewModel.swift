import Foundation

@MainActor
final class CyclingRideViewModel: ObservableObject {

    enum RideStatus: Equatable {
        case idle
        case countingDown(Int)
        case running
        case paused
    }

    @Published private(set) var status: RideStatus = .idle
    @Published private(set) var elapsedSeconds: Int = 0
    
    var onRunningStarted: (() -> Void)?

    private var startDate: Date?
    private var accumulatedSeconds: Int = 0
    private var backgroundEnteredAt: Date?
    
    private var countdownTask: Task<Void, Never>?
    private var tickerTask: Task<Void, Never>?

    deinit {
        countdownTask?.cancel()
        tickerTask?.cancel()
    }

    // MARK: - Computed

    var duration: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        return String(format: "%02dH %02dM %02dS", h, m, s)
    }

    var isCountingDown: Bool {
        if case .countingDown = status { return true }
        return false
    }

    // MARK: - Public Actions

    /// 시작 버튼: 3초 카운트다운 후 러닝 시작 + ticker 활성화
    func startWith3SecDelay() {
        guard status == .idle else { return }

        stopTicker()
        countdownTask?.cancel()

        status = .countingDown(3)

        countdownTask = Task { [weak self] in
            guard let self else { return }

            for t in stride(from: 3, through: 1, by: -1) {
                self.status = .countingDown(t)
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }
            }

            self.beginRunning()
        }
    }

    /// 러닝 <-> 일시정지 토글
    func togglePauseResume() {
        switch status {
        case .running:
            pause()
        case .paused:
            resume()
        default:
            break
        }
    }

    /// 중단: 완전 종료(카운트다운/러닝 모두 종료, 시간 0으로)
    func stopWorkout() {
        countdownTask?.cancel()
        countdownTask = nil

        stopTicker()
        resetTimeState()

        status = .idle
    }

    /// 카운트다운 취소
    func cancelCountdown() {
        guard isCountingDown else { return }
        countdownTask?.cancel()
        countdownTask = nil
        status = .idle
    }

    // MARK: - Background / Foreground Compensation

    /// 부모뷰에서 scenePhase 변화에 맞춰 호출
    func handleScenePhaseChange(_ phase: ScenePhaseLike) {
        switch phase {
        case .background:
            // 러닝 중이면 백그라운드 진입 시각 기록
            if status == .running {
                backgroundEnteredAt = Date()
            }
        case .active:
            // 러닝 중이고, 백그라운드 들어간 기록이 있으면 그 차이를 보정
            if status == .running, let bg = backgroundEnteredAt {
                let delta = Int(Date().timeIntervalSince(bg))
                if delta > 0 {
                    // Date 기반으로도 결국 elapsedSeconds는 계산되지만,
                    // ticker가 멈췄던 동안 UI 갱신이 없었을 수 있어서 즉시 갱신해줌
                    elapsedSeconds = currentElapsedSeconds(now: Date())
                }
                backgroundEnteredAt = nil
            }
        case .inactive:
            break
        }
    }

    // MARK: - Private core

    private func beginRunning() {
        // 카운트다운 종료 후 러닝 시작: 시간 초기화 후 시작
        resetTimeState()
        startDate = Date()
        status = .running
        startTicker()
        elapsedSeconds = 0
        
        onRunningStarted?()
    }

    private func pause() {
        // 지금까지 러닝한 시간을 누적에 반영하고 멈춤
        accumulatedSeconds = currentElapsedSeconds(now: Date())
        startDate = nil
        backgroundEnteredAt = nil
        stopTicker()
        status = .paused
        elapsedSeconds = accumulatedSeconds
    }

    private func resume() {
        // 누적 + 지금부터 다시 러닝
        startDate = Date()
        status = .running
        startTicker()
        elapsedSeconds = currentElapsedSeconds(now: Date())
    }

    private func resetTimeState() {
        startDate = nil
        accumulatedSeconds = 0
        backgroundEnteredAt = nil
        elapsedSeconds = 0
    }

    private func currentElapsedSeconds(now: Date) -> Int {
        // paused면 누적만, running이면 누적 + (now - startDate)
        let running = startDate.map { Int(now.timeIntervalSince($0)) } ?? 0
        return max(0, accumulatedSeconds + running)
    }

    // MARK: - Ticker (Timer 제거: Task 기반)

    private func startTicker() {
        stopTicker()

        tickerTask = Task { [weak self] in
            guard let self else { return }
            // 러닝 중에만 1초마다 UI 갱신
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }

                // 상태가 러닝일 때만 업데이트
                if self.status == .running {
                    self.elapsedSeconds = self.currentElapsedSeconds(now: Date())
                }
            }
        }
    }

    private func stopTicker() {
        tickerTask?.cancel()
        tickerTask = nil
    }
}

/// SwiftUI를 직접 import하지 않기 위해(도메인 계층 분리용) 만든 간단 래퍼
enum ScenePhaseLike {
    case active
    case inactive
    case background
}
