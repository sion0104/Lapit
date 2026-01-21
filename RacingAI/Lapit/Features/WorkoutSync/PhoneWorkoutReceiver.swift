import Foundation
import WatchConnectivity

@MainActor
final class PhoneWorkoutReceiver: NSObject, ObservableObject {
    static let shared = PhoneWorkoutReceiver()

    // 기존: 워치에서 오는 실시간 payload
    @Published private(set) var latest: LiveMetricsPayload?

    enum DeliveryState: Equatable {
        case idle
        case waitingForWatch
        case sending(command: WorkoutCommand, attempt: Int)
        case acked(WorkoutAck)
        case failed(String)

        static func == (lhs: DeliveryState, rhs: DeliveryState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.waitingForWatch, .waitingForWatch):
                return true
            case let (.sending(lc, la), .sending(rc, ra)):
                return lc == rc && la == ra
            case let (.failed(lm), .failed(rm)):
                return lm == rm
            case let (.acked(la), .acked(ra)):
                // WorkoutAck가 Equatable이 아니어도 비교할 "핵심 키"만 비교
                return la.commandId == ra.commandId
                    && la.command.rawValue == ra.command.rawValue
                    && la.status.rawValue == ra.status.rawValue
            default:
                return false
            }
        }
    }

    @Published private(set) var deliveryState: DeliveryState = .idle

    private var retryTask: Task<Void, Never>?
    private var pending: PendingCommand?

    private struct PendingCommand: Equatable {
        let command: WorkoutCommand
        let commandId: String
        var attempt: Int
    }

    private override init() {
        super.init()
        activate()
    }

    private func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    // MARK: - Public API (eventually 보장)

    func sendEventually(_ command: WorkoutCommand) {
        let cmdId = UUID().uuidString
        pending = PendingCommand(command: command, commandId: cmdId, attempt: 0)

        retryTask?.cancel()
        retryTask = Task { [weak self] in
            guard let self else { return }
            await self.retryLoop()
        }
    }

    // MARK: - Retry core

    private func retryLoop() async {
        guard var p = pending else { return }

        while !Task.isCancelled, pending?.commandId == p.commandId {
            p.attempt += 1
            pending = p
            deliveryState = .sending(command: p.command, attempt: p.attempt)

            let immediateSent = sendMessageIfReachable(command: p.command, commandId: p.commandId)

            if !immediateSent {
                // Reachable 아니면 “배송 예약”
                enqueueUserInfo(command: p.command, commandId: p.commandId)
                deliveryState = .waitingForWatch
            }

            // backoff: 0.5 → 1 → 2 → 3 → 5 (상한 5s)
            let delay = min(5.0, 0.5 * pow(2.0, Double(min(p.attempt - 1, 4))))
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }

    private func sendMessageIfReachable(command: WorkoutCommand, commandId: String) -> Bool {
        guard WCSession.isSupported() else { return false }
        let s = WCSession.default
        guard s.activationState == .activated else { return false }
        guard s.isReachable else { return false }

        let msg: [String: Any] = [
            "command": command.rawValue,
            "commandId": commandId
        ]

        s.sendMessage(msg, replyHandler: nil) { error in
            print("❌ sendMessage error:", error)
        }
        return true
    }

    private func enqueueUserInfo(command: WorkoutCommand, commandId: String) {
        guard WCSession.isSupported() else { return }
        let s = WCSession.default
        guard s.activationState == .activated else { return }

        s.transferUserInfo([
            "command": command.rawValue,
            "commandId": commandId
        ])
        print("📦 transferUserInfo queued:", command.rawValue, commandId)
    }

    private func completeIfMatches(_ ack: WorkoutAck) {
        guard pending?.commandId == ack.commandId else { return }
        deliveryState = .acked(ack)
        pending = nil
        retryTask?.cancel()
        retryTask = nil
    }
}

// MARK: - WCSessionDelegate
extension PhoneWorkoutReceiver: WCSessionDelegate {
    nonisolated func session(_ session: WCSession,
                             activationDidCompleteWith activationState: WCSessionActivationState,
                             error: Error?) { }

    #if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) { }
    nonisolated func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif

    // 워치 → iPhone 실시간 메트릭 수신 (기존 유지)
    nonisolated func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        do {
            let payload = try JSONDecoder().decode(LiveMetricsPayload.self, from: messageData)
            Task { @MainActor in self.latest = payload }
        } catch {
            print("❌ decode payload fail:", error)
        }
    }

    // 워치 → iPhone ACK 수신 (추가)
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // ack 패킷만 처리
        guard let data = try? JSONSerialization.data(withJSONObject: message, options: []),
              let ack = try? JSONDecoder().decode(WorkoutAck.self, from: data) else { return }

        Task { @MainActor in
            self.completeIfMatches(ack)
        }
    }
}

