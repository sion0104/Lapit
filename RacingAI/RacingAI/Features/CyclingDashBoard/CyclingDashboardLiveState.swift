import Foundation

@MainActor
final class CyclingDashboardLiveState: ObservableObject {
    @Published private(set) var current: LiveMetricsPayload?
    @Published private(set) var previousBPM: Int = 0
    @Published private(set) var previousLabel: String = ""
    @Published private(set) var bpmDeltaText: String = ""

    func update(with payload: LiveMetricsPayload) {
        let newBPM = MetricFormatter.bpmInt(payload.heartRateBPM)
        if let currentBPM = current.map({ MetricFormatter.bpmInt($0.heartRateBPM) }), currentBPM != 0 {
            previousBPM = currentBPM
            previousLabel = "이전"
            bpmDeltaText = "\(newBPM - currentBPM)"
        } else {
            previousBPM = 0
            previousLabel = ""
            bpmDeltaText = ""
        }
        current = payload
    }
}
