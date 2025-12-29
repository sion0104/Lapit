import SwiftUI

struct StartView: View {
    @State private var canNavigate: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("맞춤 플래너 사용을 위해\n몸 상태를 체크할게요")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                Text("부상 예방과 회복 속도 조절에 꼭 필요합니다")
                    .font(.callout)
                    .padding(.top, 5)
                
                Spacer()
                
                
            }
            .padding()
            .navigationDestination(isPresented: $canNavigate) {
                FirstQuestionView()
            }
            .safeAreaInset(edge: .bottom) {
                AppButton(
                    title: "설문 시작하기",
                    isEnabled: true
                ) {
                    canNavigate = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)

    }
}

#Preview {
    StartView()
}
