import SwiftUI
import WatchConnectivity

struct ContentView: View {
    var body: some View {
        Button("Send Mock Metrics") {
            let payload = LiveMetricsPayload(
                timestamp: Date(),
                heartRateBPM: 132,
                activeEnergyKcal: 88,
                distanceMeters: 1200,
                speedMps: 5.2
            )

            do {
                let data = try JSONEncoder().encode(payload)
                WCSession.default.sendMessageData(data, replyHandler: nil, errorHandler: nil)
            } catch {
                print(error)
            }
        }

    }
}

#Preview {
    ContentView()
}
