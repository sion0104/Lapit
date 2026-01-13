import Foundation
import WatchConnectivity

final class WatchCommandReceiver: NSObject, WCSessionDelegate {
    static let shared = WatchCommandReceiver()

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

    // MARK: - WCSessionDelegate
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) { }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("✅ didReceiveMessage:", message)

        guard let raw = message["command"] as? String,
              let cmd = WorkoutCommand(rawValue: raw) else {
            print("❌ command parse fail")
            return
        }

        Task { @MainActor in
            print("✅ command:", cmd)
            switch cmd {
            case .startCycling:
                await WatchWorkoutManager.shared.startCycling()
            case .pause:
                await WatchWorkoutManager.shared.pause()
            case .resume:
                await WatchWorkoutManager.shared.resume()
            case .stop:
                await WatchWorkoutManager.shared.stop()
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) { }
}
