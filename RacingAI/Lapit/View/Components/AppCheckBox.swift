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
            if isOn {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.selectedCheckBox)
                    .frame(width: 24, height: 24)
                Image(systemName: "checkmark")
                    .foregroundStyle(.select)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.checkBox)
                    .frame(width: 24, height: 24)
            }
        }
    }
}

