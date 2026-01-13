import Foundation

@MainActor
final class CyclingDashboardLiveState: ObservableObject {
    @Published private(set) var previousBPM: Int = 0
    @Published private(set) var previousLabel: String = ""
    @Published private(set) var bpmDeltaText: String = ""
    
    private var lastBPM: Int?

    func update(with payload: LiveMetricsPayload) {
        let bpm = MetricFormatter.bpmInt(payload.heartRateBPM)
        
        if let last = lastBPM, last > 0 {
            previousBPM = last
            previousLabel = "이전"
            let delta = bpm - last
            bpmDeltaText = delta == 0 ? "0" : (delta > 0 ? "+\(delta)" : "\(delta)")
        } else {
            previousBPM = 0
            previousLabel = ""
            bpmDeltaText = ""
        }
        
        lastBPM = bpm
    }
}
