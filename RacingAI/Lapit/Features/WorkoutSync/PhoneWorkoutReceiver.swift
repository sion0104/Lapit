import Foundation
import WatchConnectivity

@MainActor
final class PhoneWorkoutReceiver: NSObject, ObservableObject {
    static let shared = PhoneWorkoutReceiver()

    @Published private(set) var latest: LiveMetricsPayload?

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

    func sendCommand(_ command: WorkoutCommand) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated else { return }

        session.sendMessage(["command": command.rawValue], replyHandler: nil, errorHandler: nil)
    }
}

extension PhoneWorkoutReceiver: WCSessionDelegate {
    nonisolated func session(_ session: WCSession,
                             activationDidCompleteWith activationState: WCSessionActivationState,
                             error: Error?) { }

    #if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) { }
    nonisolated func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif

    nonisolated func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("📩 didReceiveMessageData size:", messageData.count)

        do {
            let payload = try JSONDecoder().decode(LiveMetricsPayload.self, from: messageData)
            Task { @MainActor in
                print("✅ payload:", payload)
                self.latest = payload
            }
        } catch {
            print("❌ decode fail:", error)
        }
    }
}
