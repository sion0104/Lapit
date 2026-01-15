import Foundation

@MainActor
final class CyclingDashboardLiveState: ObservableObject {

    @Published private(set) var currentDistanceMeters: Double? = nil
    @Published private(set) var currentSpeedMps: Double? = nil
    @Published private(set) var currentCaloriesKcal: Double? = nil
    @Published private(set) var currentBPM: Int = 0

    @Published private(set) var previousBPM: Int = 0
    @Published private(set) var previousLabel: String = ""
    @Published private(set) var bpmDeltaText: String = ""

    private var lastValidBPM: Int? = nil

    private var lastValidSpeedMps: Double? = nil
    private var lastSpeedAt: Date? = nil
    var speedHoldSec: TimeInterval = 2.0

    func reset() {
        currentDistanceMeters = nil
        currentSpeedMps = nil
        currentCaloriesKcal = nil
        currentBPM = 0

        previousBPM = 0
        previousLabel = ""
        bpmDeltaText = ""

        lastValidBPM = nil
        lastValidSpeedMps = nil
        lastSpeedAt = nil
    }

    func update(with payload: LiveMetricsPayload) {
        currentDistanceMeters = payload.distanceMeters
        currentCaloriesKcal = payload.activeEnergyKcal

        let now = payload.timestamp
        if let sp = payload.speedMps, sp > 0 {
            lastValidSpeedMps = sp
            lastSpeedAt = now
            currentSpeedMps = sp
        } else {
            if let lastAt = lastSpeedAt,
               now.timeIntervalSince(lastAt) <= speedHoldSec,
               let hold = lastValidSpeedMps {
                currentSpeedMps = hold
            } else {
                currentSpeedMps = payload.speedMps
            }
        }

        let bpm = MetricFormatter.bpmInt(payload.heartRateBPM)
        guard bpm > 0 else { return }

        currentBPM = bpm

        if let last = lastValidBPM {
            previousBPM = last
            previousLabel = "이전"
            let delta = bpm - last
            bpmDeltaText = delta == 0 ? "0" : (delta > 0 ? "+\(delta)" : "\(delta)")
        } else {
            previousBPM = 0
            previousLabel = ""
            bpmDeltaText = ""
        }

        lastValidBPM = bpm
    }
}
