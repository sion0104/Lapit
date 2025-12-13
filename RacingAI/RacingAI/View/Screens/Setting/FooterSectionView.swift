import SwiftUI

struct FooterSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Button(role: .destructive) {
                    // 로그아웃 액션
                } label: {
                    Text("로그아웃")
                        .font(.footnote)
                        .foregroundStyle(.black)
                }
                
                Button {
                    // 회원 탈퇴
                } label: {
                    Text("회원 탈퇴")
                        .font(.footnote)
                        .foregroundStyle(Color("SecondaryFont"))
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("AI 운동 플래너 ver 1.1.0")
                    .font(.caption)
                    .foregroundStyle(Color("Footer"))
                
                Text("문의 매일 | jyunju99@naver.com")
                    .font(.caption)
                    .foregroundStyle(Color("Footer"))
            }
        }
    }
}

#Preview {
    FooterSectionView()
}
