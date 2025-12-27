import Foundation

struct LiveMetricsPayload: Codable {
    var timestamp: Date
    
    var heartRateBPM: Double?
    var activeEnergyKcal: Double?
    var distanceMeters: Double?
    
    var speedMps: Double?
}
