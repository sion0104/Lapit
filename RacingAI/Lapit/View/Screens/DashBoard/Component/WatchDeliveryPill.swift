import SwiftUI

struct WatchDeliveryPill: View {
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .frame(width: 6, height: 6)

            Text(text)
                .font(.caption2)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
    }
}
