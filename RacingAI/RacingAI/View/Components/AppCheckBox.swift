import SwiftUI

struct AppCheckBox: View {
    @Binding var isOn: Bool
    var size: CGFloat = 24
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button {
            isOn.toggle()
            action?()
        } label: {
            ZStack {
                Rectangle()
                    .fill(Color("Button"))
                    .frame(width: size, height: size)
                if isOn {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.black)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isOn ? "체크됨" : "체크 해제")
    }
}
