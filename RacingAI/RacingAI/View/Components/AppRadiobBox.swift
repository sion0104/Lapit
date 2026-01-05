import SwiftUI

struct AppRadiobBox: View {
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
            Circle()
                .fill(.white)
                .stroke(.button)
                .frame(width: 24, height: 24)
            if isOn {
                Circle()
                    .fill(.main)
                    .frame(width: 12, height: 12)
            }
        }
    }
}
