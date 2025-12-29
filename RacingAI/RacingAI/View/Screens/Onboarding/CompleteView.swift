import SwiftUI

struct CompleteView: View {
    var body: some View {
        Spacer()
        
        VStack(spacing: 10) {
            Text("가입이 완료되었습니다!")
                .font(.system(size: 24).bold())
                .fontWeight(.bold)
            
            Text("맞춤형 운동 플래너를 사용해보세요")
                .font(.callout)
        }
        
        Spacer()
    }
}

#Preview {
    CompleteView()
}
