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
            
            AppButton(title: rightTitle, isEnabled: isRightEnabled) {
                rightAction()
            }
        }
        .padding()
        .background(Color.white)
    }
}
