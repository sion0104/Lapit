import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 19)
            .padding(.vertical, 17)
            .background(
                Color(.main)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .foregroundStyle(.black)
            .font(.headline)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
