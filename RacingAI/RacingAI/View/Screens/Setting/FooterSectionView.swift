import SwiftUI

struct FooterSectionView: View {
    
    @EnvironmentObject private var userSession: UserSessionStore
    
    @State private var showLogoutAlert: Bool = false
    
    @State private var showWithdrawAlert: Bool = false
    @State private var isWithdrawing: Bool = false
    @State private var toastMessage: String? = nil
    
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
        .alert("회원 탈퇴", isPresented: $showWithdrawAlert) {
            Button("취소", role: .cancel) {}
            Button("탈퇴", role: .destructive) {
                Task { await withdraw() }
            }
        } message: {
            Text("탈퇴 시 계정 정보가 삭제되며 복구할 수 없습니다.\n정말 탈퇴하시겠습니까?")
        }
        .alert("안내", isPresented: .constant(toastMessage != nil)) {
            Button("확인") { toastMessage = nil }
        } message: {
            Text(toastMessage ?? "")
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
                showWithdrawAlert = true
            } label: {
                HStack {
                    Text("회원 탈퇴")
                        .font(.footnote)
                        .foregroundStyle(Color("SecondaryFont"))
                    if isWithdrawing {
                        ProgressView().scaleEffect(0.8)
                    }
                }
            }
            .disabled(isWithdrawing)
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
    
    private func withdraw() async {
        isWithdrawing = true
        defer { isWithdrawing = false }
        
        do {
            try await userSession.withdraw()
        } catch {
            toastMessage = describeAPIError(error)
        }
    }
}

#Preview {
    FooterSectionView()
}
