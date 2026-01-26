import SwiftUI

struct LoadingOverlayView: View {
    let text: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.15).ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
