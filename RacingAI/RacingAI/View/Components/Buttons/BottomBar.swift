import SwiftUI

struct BottomBar: View {
    let leftTitle: String
    let rightTitle: String
    var isLeftEnabled: Bool = true
    var isRightEnabled: Bool = true
    let leftAction: () -> Void
    let rightAction: () -> Void
    
    var body: some View {
        HStack {
            AppButton(title: leftTitle, isEnabled: isLeftEnabled) {
                leftAction()
            }
            .frame(width: 122)
            .buttonStyle(SecondaryButtonStyle())
            
            AppButton(title: rightTitle, isEnabled: isRightEnabled) {
                rightAction()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .background(Color.white)
    }
}
