import SwiftUI

struct FooterSectionView: View {
    
    @EnvironmentObject private var userSession: UserSessionStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if userSession.isLoggedIn {
                loggedInButtons
            } else {
                loggedOutButtons
            }
            
            footerInfo
        }
    }
    
    private var loggedInButtons: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(role: .destructive) {
                userSession.logout()
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
    }
    
    private var loggedOutButtons: some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink {
                // 로그인 화면
                Text("로그인 화면")
            } label: {
                 Text("로그인")
                    .font(.footnote)
                    .foregroundStyle(.black)
            }
        }
    }
    
    private var footerInfo: some View {
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

#Preview {
    FooterSectionView()
}
