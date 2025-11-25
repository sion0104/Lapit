import SwiftUI

struct AppCheckBox: View {
    @Binding var isOn: Bool
    var size: CGFloat = 24
    var isTapEnabled: Bool = true
    var action: (() -> Void)? = nil
    
    var body: some View {
        Group {
            if isTapEnabled {
                Button {
                    isOn.toggle()
                    action?()
                } label: {
                    box
                }
                .buttonStyle(.plain)
            } else {
                box
            }
        }
        .accessibilityLabel(isOn ? "체크됨" : "체크 해제")
    }
    
    private var box: some View {
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
}
