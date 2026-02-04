import SwiftUI

struct AppleWeatherAttributionView: View {
    var body: some View {
        HStack(spacing: 4) {
            Text(" Weather")
                .font(.caption2)
                .fontWeight(.medium)

            Text("•")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Link(
                "Legal Attribution",
                destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!
            )
            .font(.caption2)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
