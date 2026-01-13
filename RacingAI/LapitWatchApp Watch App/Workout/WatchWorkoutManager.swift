import Foundation
import HealthKit
import WatchConnectivity

@MainActor
final class WatchWorkoutManager: NSObject, ObservableObject {
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

    override private init() {
        super.init()
        activateWCSessionIfNeeded()
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
            session.sendMessageData(data, replyHandler: nil) { error in
                print("❌ sendMessageData error:", error)
            }
        } catch {
            print("❌ encode error:", error)
        }
    }

    private func makePayload(now: Date) -> LiveMetricsPayload {
        guard let builder = workoutBuilder else {
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
                                    date: Date) { }

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didFailWithError error: Error) {
        Task { @MainActor in
            print("❌ workoutSession failed:", error)
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

extension WatchWorkoutManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession,
                             activationDidCompleteWith activationState: WCSessionActivationState,
                             error: Error?) {
        if let error {
            print("❌ WCSession activate error:", error)
        } else {
            print("✅ WCSession activated:", activationState.rawValue)
        }
    }
}
