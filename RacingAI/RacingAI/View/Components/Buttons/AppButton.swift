import SwiftUI

struct AppButton: View {
    var title: String
    var isEnabled: Bool
    var isLeading: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button {
            if isEnabled {
                action()
            }
        } label: {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)
                if isLeading {
                    Spacer()
                }
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.6)
        .accessibilityLabel(title)
    }
}
