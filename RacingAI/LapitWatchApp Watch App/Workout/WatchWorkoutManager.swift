import Foundation
import HealthKit
import WatchConnectivity

@MainActor
final class WatchWorkoutManager: NSObject, ObservableObject, WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    static let shared = WatchWorkoutManager()
    
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var lastPayload: LiveMetricsPayload?

    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?

    private var lastDistanceMeters: Double?
    private var lastDistanceAt: Date?
    
    private var lastSentAt: Date?
    
    private var isStopping: Bool = false
    
    // WatchWorkoutManager 내부에 추가
    private var pendingStartCommandId: String?
    private var pendingStartCommand: WorkoutCommand?
    
    private var lastQueuedUserInfoAt: Date?
    var minUserInfoIntervalSec: TimeInterval = 2.0

    func setPendingCommandId(command: WorkoutCommand, commandId: String) {
        // start에 대해 running ACK를 정확히 보내기 위해 저장
        if command == .startCycling {
            pendingStartCommand = command
            pendingStartCommandId = commandId
        }
    }

    func sendAck(command: WorkoutCommand, commandId: String, status: WorkoutAckStatus, message: String?) {
        guard WCSession.isSupported() else { return }
        let s = WCSession.default
        guard s.activationState == .activated else { return }

        let ack = WorkoutAck(
            command: command,
            commandId: commandId,
            status: status,
            timestamp: Date(),
            message: message
        )

        guard let data = try? JSONEncoder().encode(ack),
              let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else { return }

        if s.isReachable {
            s.sendMessage(json, replyHandler: nil) { error in
                print("❌ ACK sendMessage error:", error)
                s.transferUserInfo(["ackData": data])
            }
        } else {
            // ✅ 워치가 백그라운드/폰이 일시 단절이어도 eventually 전달
            s.transferUserInfo(["ackData": data])
        }
    }


    override private init() {
        super.init()
    }
    
    private func activateWCSessionIfNeeded(){
        guard WCSession.isSupported() else { return }
        let wc = WCSession.default
        wc.delegate = self
        wc.activate()
    }

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.workoutType()
        ]

        let shareTypes: Set<HKSampleType> = [
            HKObjectType.workoutType()
        ]

        try await healthStore.requestAuthorization(toShare: shareTypes, read: readTypes)
    }

    func startCycling() async {
        print("🚴 startCycling called")
        
        do { try await requestAuthorization() }
        catch {
            print("❌ auth fail:", error)
            return
        }

        if workoutSession != nil {
            print("⚠️ already running")
            return
        }
        
        let config = HKWorkoutConfiguration()
        config.activityType = .cycling
        config.locationType = .outdoor

        do {
            let newSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            let newBuilder = newSession.associatedWorkoutBuilder()
            
            self.workoutSession = newSession
            self.workoutBuilder = newBuilder
            
            newSession.delegate = self
            newBuilder.delegate = self
            
            newBuilder.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: config
            )
            
            let startDate = Date()
            workoutSession?.startActivity(with: startDate)
            print("✅ session.startActivity")

            try await workoutBuilder?.beginCollection(at: startDate)
            print("✅ beginCollection")
            
            self.isRunning = true
            self.isStopping = false
            self.lastDistanceMeters = nil
            self.lastDistanceAt = nil
            self.lastSentAt = nil

        } catch {
            print("❌ startCycling error:", error)
            await cleanupAfter()
        }
    }

    func pause() async { workoutSession?.pause() }
    func resume() async { workoutSession?.resume() }

    func stop() async {
        
        if isStopping { return }
        isStopping = true
        
        guard let session = workoutSession, let builder = workoutBuilder else {
            await cleanupAfter()
            return
        }
        
        session.end()
        
        do {
            try await builder.endCollection(at: Date())
            _ = try await builder.finishWorkout()

        } catch {
            
        }
        
        await cleanupAfter()
    }
    
    private func cleanupAfter() async {
        self.workoutSession = nil
        self.workoutBuilder = nil
        
        self.lastDistanceMeters = nil
        self.lastDistanceAt = nil
        self.lastSentAt = nil
        
        self.isRunning = false
        self.isStopping = false
    }

    private func sendToPhone(_ payload: LiveMetricsPayload) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated else { return }

        do {
            let data = try JSONEncoder().encode(payload)

            if session.isReachable {
                session.sendMessageData(data, replyHandler: nil) { error in
                    print("❌ sendMessageData error:", error)
                    self.enqueuePayloadIfNeeded(session: session, data: data)
                }
                return
            }

            enqueuePayloadIfNeeded(session: session, data: data)

        } catch {
            print("❌ encode error:", error)
        }
    }

    private func enqueuePayloadIfNeeded(session: WCSession, data: Data) {
        let now = Date()

        if let last = lastQueuedUserInfoAt,
           now.timeIntervalSince(last) < minUserInfoIntervalSec {
            return
        }

        lastQueuedUserInfoAt = now
        session.transferUserInfo(["payloadData": data])
    }
    
    private func makePayload(now: Date) -> LiveMetricsPayload {
        guard workoutBuilder != nil else {
            return LiveMetricsPayload(
                timestamp: now,
                heartRateBPM: nil,
                activeEnergyKcal: nil,
                distanceMeters: nil,
                speedMps: nil
            )
        }
        
        let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let kcalType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let distType = HKQuantityType.quantityType(forIdentifier: .distanceCycling)!

        let hr = workoutBuilder?.statistics(for: hrType)?
            .mostRecentQuantity()?
            .doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))

        let kcal = workoutBuilder?.statistics(for: kcalType)?
            .sumQuantity()?
            .doubleValue(for: .kilocalorie())

        let dist = workoutBuilder?.statistics(for: distType)?
            .sumQuantity()?
            .doubleValue(for: .meter())

        var speedMps: Double? = nil
        if let dist {
            if let last = lastDistanceMeters, let lastAt = lastDistanceAt {
                let dt = now.timeIntervalSince(lastAt)
                if dt > 0 { speedMps = max(0, (dist - last) / dt) }
            }
            lastDistanceMeters = dist
            lastDistanceAt = now
        }

        return LiveMetricsPayload(
            timestamp: now,
            heartRateBPM: hr,
            activeEnergyKcal: kcal,
            distanceMeters: dist,
            speedMps: speedMps
        )
    }
    
    private func shouldSent(now: Date) -> Bool {
        if let last = lastSentAt, now.timeIntervalSince(last) < 1.0 {
            return false
        }
        lastSentAt = now
        return true
    }
}

extension WatchWorkoutManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didChangeTo toState: HKWorkoutSessionState,
                                    from fromState: HKWorkoutSessionState,
                                    date: Date) {
        Task { @MainActor in
            // “진짜 running” 시점
            if toState == .running,
               let cmd = self.pendingStartCommand,
               let cmdId = self.pendingStartCommandId {
                self.sendAck(command: cmd, commandId: cmdId, status: .started, message: nil)
                self.pendingStartCommand = nil
                self.pendingStartCommandId = nil
            }

            // ended 상태는 stop 쪽에서 이미 ack를 보내고 있지만,
            // 필요하면 여기서도 추가 방어 가능
        }
    }

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didFailWithError error: Error) {
        Task { @MainActor in
            print("❌ workoutSession failed:", error)

            // start pending이 있었는데 실패했다면 failed ACK
            if let cmd = self.pendingStartCommand,
               let cmdId = self.pendingStartCommandId {
                self.sendAck(command: cmd, commandId: cmdId, status: .failed, message: error.localizedDescription)
                self.pendingStartCommand = nil
                self.pendingStartCommandId = nil
            }

            await self.cleanupAfter()
        }
    }
}

extension WatchWorkoutManager: HKLiveWorkoutBuilderDelegate {

    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) { }

    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                                    didCollectDataOf collectedTypes: Set<HKSampleType>) {

        Task { @MainActor [weak self] in
            guard let self else { return }
            guard self.isRunning else { return }
            
            let now = Date()
            guard self.shouldSent(now: now) else { return }
            self.lastSentAt = now
            
            let payload = self.makePayload(now: now)
            self.lastPayload = payload
            self.sendToPhone(payload)
        }
    }
}
