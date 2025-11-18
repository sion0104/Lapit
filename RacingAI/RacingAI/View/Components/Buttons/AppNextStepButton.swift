import SwiftUI

struct AppNextStepButton: View {
    var title: String = "다음 단계"
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
        .modifier(ButtonStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.6)
        .accessibilityLabel(title)
    }
}
