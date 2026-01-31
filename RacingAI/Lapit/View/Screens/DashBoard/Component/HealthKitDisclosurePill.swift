import SwiftUI

struct HealthKitDisclosurePill: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "heart.fill")
                .font(.caption)
            Text("심박수 및 운동 데이터는 Apple 건강(HealthKit)에서 가져옵니다.")
                .font(.caption2)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
    }
}
