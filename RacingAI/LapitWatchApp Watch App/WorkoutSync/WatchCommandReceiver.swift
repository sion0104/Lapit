import Foundation
import WatchConnectivity

final class WatchCommandReceiver: NSObject, @preconcurrency WCSessionDelegate {
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

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) { }

    func sessionReachabilityDidChange(_ session: WCSession) { }

    @MainActor
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handle(dict: message)
    }

    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        Task { @MainActor in
            handle(dict: message)
            replyHandler([:]) // 필요 없으면 빈 응답
        }
    }

    @MainActor
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handle(dict: userInfo)
    }

    @MainActor
    private func handle(dict: [String: Any]) {
        guard let raw = dict["command"] as? String,
              let cmd = WorkoutCommand(rawValue: raw) else {
            print("❌ command parse fail")
            return
        }

        let commandId = (dict["commandId"] as? String) ?? UUID().uuidString

        // 1) received ACK
        WatchWorkoutManager.shared.sendAck(command: cmd, commandId: commandId, status: .received, message: nil)

        // 2) 실제 수행
        Task { @MainActor in
            WatchWorkoutManager.shared.setPendingCommandId(command: cmd, commandId: commandId)

            switch cmd {
            case .startCycling:
                await WatchWorkoutManager.shared.startCycling()
            case .pause:
                await WatchWorkoutManager.shared.pause()
                WatchWorkoutManager.shared.sendAck(command: cmd, commandId: commandId, status: .paused, message: nil)
            case .resume:
                await WatchWorkoutManager.shared.resume()
                WatchWorkoutManager.shared.sendAck(command: cmd, commandId: commandId, status: .resumed, message: nil)
            case .stop:
                await WatchWorkoutManager.shared.stop()
                WatchWorkoutManager.shared.sendAck(command: cmd, commandId: commandId, status: .stopped, message: nil)
            }
        }
    }
}
