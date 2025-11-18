import SwiftUI

struct ContentView: View {
    
    @State private var userId: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            AppTextField(
                text: $userId,
                placeholder: "아이디를 입력해주세요",
                keyboard: .emailAddress,
                submitLabel: .next,
                error: userId.isEmpty ? nil: (userId.count < 4 ? "아이디는 4자 이상이어야 합니다." : nil)
            )
            
            AppNextStepButton(isEnabled: true) {
                
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
