import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 19)
            .padding(.vertical, 17)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("Button"))
            )
            .foregroundStyle(.black)
            .font(.headline)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
