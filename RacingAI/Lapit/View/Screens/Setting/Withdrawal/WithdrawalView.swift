import SwiftUI

struct WithdrawalView: View {
    @EnvironmentObject private var userSession: UserSessionStore

    @State private var isWithdrawing: Bool = false
    @State private var showWidthdrawAlert: Bool = false
    @State private var toastMessage: String? = nil
    
    let onBack: () -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 20) {
                Text("탈퇴 전 아래 내용을 꼭 확인해주세요")
                    .font(.title3)
            
            VStack(spacing: 10) {
                Text("· 탈퇴 시 회원님의 모든 훈련 기록과 분석 데이터가 즉시 삭제되며, 복구가 불가능합니다.")
                    .font(.footnote)
                    .fontWeight(.bold)
                
                Text("· AI 코치 추천 기록, 훈련 점수, 회복 지표, 효율 데이터도 함께 삭제됩니다.")
                    .font(.footnote)
                    .fontWeight(.bold)
                
                Text("· Apple Watch 등 연동 기기 연결 정보도 자동해제 됩니다")
                    .font(.footnote)
                    .fontWeight(.bold)
                
                Text("· 탈퇴 후에는 동일 계정으로 재가입 시 기존 데이터가   복원되지 않습니다.")
                    .font(.footnote)
                    .fontWeight(.bold)
                
                Text("· 단, 관계 법령에 따라 일정 기간 보존이 필요한 최소한의 정보는 법정 기간 동안 보관됩니다.")
                    .font(.footnote)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .preference(key: TabBarHiddenPreferenceKey.self, value: true)
        .safeAreaInset(edge: .bottom, content: {
            AppButton(title: isWithdrawing ? "탈퇴 처리 중..." : "탈퇴하기", isEnabled: !isWithdrawing) {
                showWidthdrawAlert = true
            }
            .padding()
            .buttonStyle(PrimaryButtonStyle())
        })
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 5) {
                    Button { onBack() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.black)
                    }
                    
                    Text("회원 탈퇴")
                        .font(.title3)
                        .foregroundStyle(Color("Chevron"))
                        .fontWeight(.medium)
                }
            }
        }
        .alert("회원 탈퇴", isPresented: $showWidthdrawAlert) {
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
    
    private func withdraw() async {
        isWithdrawing = true
        defer { isWithdrawing = false }
        
        do {
            try await userSession.withdraw()
            onComplete()
        } catch {
            toastMessage = describeAPIError(error)
        }
    }
}

#Preview {
    WithdrawalView(onBack: {}, onComplete: {})
        .environmentObject(UserSessionStore())
}
