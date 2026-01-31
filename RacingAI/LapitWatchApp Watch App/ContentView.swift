import SwiftUI

struct ContentView: View {
    @StateObject private var manager = WatchWorkoutManager.shared

    var body: some View {
        VStack(spacing: 10) {

            VStack(alignment: .leading, spacing: 6) {
                Text(manager.isRunning ? "Workout: Running" : "Workout: Idle")
                    .font(.headline)

                if let p = manager.lastPayload {
                    Text("HR: \(Int(p.heartRateBPM ?? 0)) bpm")
                    Text("Dist: \(Int(p.distanceMeters ?? 0)) m")
                    Text("Kcal: \(Int(p.activeEnergyKcal ?? 0)) kcal")
                } else {
                    Text("No metrics yet")
                        .foregroundStyle(.secondary)
                }

                if !manager.sendStatusText.isEmpty {
                    Text(manager.sendStatusText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            #if DEBUG
            Button("Test Connection") {
                manager.sendMockMetricsForDebug()
            }
            .buttonStyle(.borderedProminent)
            #endif
        }
        .padding()
    }
}
