import SwiftUI

struct FooterSectionView: View {
    
    @EnvironmentObject private var userSession: UserSessionStore
    
    let onWithdrawTap: () -> Void
    
    @State private var showLogoutAlert: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if userSession.isLoggedIn {
                loggedInButtons
            } else {
                loggedOutButtons
            }
            
            footerInfo
        }
        .alert("로그아웃",isPresented: $showLogoutAlert) {
            Button("취소", role: .cancel) {}
            Button("로그아웃", role: .destructive) {
                userSession.logout()
            }
        } message: {
            Text("정말 로그아웃 하시겠습니까?")
        }
    }
    
    private var loggedInButtons: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(role: .destructive) {
                showLogoutAlert = true
            } label: {
                Text("로그아웃")
                    .font(.footnote)
                    .foregroundStyle(.black)
            }
            
            Button(role: .destructive) {
                onWithdrawTap()
            } label: {
                HStack {
                    Text("회원 탈퇴")
                        .font(.footnote)
                        .foregroundStyle(Color("SecondaryFont"))
                }
            }
        }
    }
    
    private var loggedOutButtons: some View {
        VStack(alignment: .leading, spacing: 10) {
            NavigationLink {
                LoginView()
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
    FooterSectionView(onWithdrawTap: {})
        .environmentObject(UserSessionStore())
}
