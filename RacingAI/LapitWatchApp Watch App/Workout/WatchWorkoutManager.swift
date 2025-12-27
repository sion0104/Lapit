import Foundation
import HealthKit
import WatchConnectivity

@MainActor
final class WatchWorkoutManager: NSObject, ObservableObject {
    static let shared = WatchWorkoutManager()

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    private var lastDistanceMeters: Double?
    private var lastDistanceAt: Date?

    override private init() { super.init() }

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
        do { try await requestAuthorization() }
        catch { return }

        if session != nil { return }

        let config = HKWorkoutConfiguration()
        config.activityType = .cycling
        config.locationType = .outdoor

        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            let builder = session.associatedWorkoutBuilder()

            self.session = session
            self.builder = builder

            session.delegate = self
            builder.delegate = self
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)

            let startDate = Date()
            session.startActivity(with: startDate)
            
            try await builder.beginCollection(at: startDate)
            
        } catch { }
    }

    func pause() async { session?.pause() }
    func resume() async { session?.resume() }

    func stop() async {
        guard let session, let builder else { return }
        session.end()
        
        do {
            try await builder.endCollection(at: Date())
                        _ = try await builder.finishWorkout()

        } catch {
            
        }


        self.session = nil
        self.builder = nil
        self.lastDistanceMeters = nil
        self.lastDistanceAt = nil
    }

    private func sendToPhone(_ payload: LiveMetricsPayload) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        guard session.activationState == .activated else { return }

        do {
            let data = try JSONEncoder().encode(payload)
            session.sendMessageData(data, replyHandler: nil, errorHandler: nil)
        } catch { }
    }

    private func makePayload(now: Date) -> LiveMetricsPayload {
        let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let kcalType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let distType = HKQuantityType.quantityType(forIdentifier: .distanceCycling)!

        let hr = builder?.statistics(for: hrType)?
            .mostRecentQuantity()?
            .doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))

        let kcal = builder?.statistics(for: kcalType)?
            .sumQuantity()?
            .doubleValue(for: .kilocalorie())

        let dist = builder?.statistics(for: distType)?
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
}

extension WatchWorkoutManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didChangeTo toState: HKWorkoutSessionState,
                                    from fromState: HKWorkoutSessionState,
                                    date: Date) { }

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didFailWithError error: Error) { }
}

extension WatchWorkoutManager: HKLiveWorkoutBuilderDelegate {

    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) { }

    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                                    didCollectDataOf collectedTypes: Set<HKSampleType>) {

        Task { @MainActor [weak self] in
            guard let self else { return }
            let payload = self.makePayload(now: Date())
            self.sendToPhone(payload)
        }
    }
}
