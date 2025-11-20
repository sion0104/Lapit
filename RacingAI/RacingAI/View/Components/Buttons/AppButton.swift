import SwiftUI

struct AppButton: View {
    var title: String
    var isEnabled: Bool
    var action: () -> Void
    
    var body: some View {
        Button {
            if isEnabled {
                action()
            }
        } label: {
            Text(title)
                .foregroundStyle(.primary)
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.6)
        .accessibilityLabel(title)
    }
}
