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
                if isLeading {
                    Text(title)
                        .foregroundStyle(.primary)
                        .padding(.leading, 20)
                    Spacer()
                } else {
                    Spacer()
                    
                    Text(title)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
            }
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.6)
        .accessibilityLabel(title)
    }
}

#Preview {
    AppButton(title: "뒤로가기", isEnabled: true, isLeading: true) {
        
    }
    .border(.black)
}
