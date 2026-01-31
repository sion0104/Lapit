import SwiftUI

struct MypageSettingView: View {
    @EnvironmentObject private var userSession: UserSessionStore
    @State private var path = NavigationPath()
    
    private var isLoggedIn: Bool {
        userSession.user != nil
    }
    
    var body: some View {
        NavigationStack(path: $path){
            ScrollView {
                VStack(alignment:.leading, spacing: 20) {
                    Text("마이페이지 및 설정")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    ProfileSectionView()
                    
                    HealthKitDisclosureCard()
                        .padding(.top, 4)
                   
                    if isLoggedIn {
                        SettingSection(title: "설정") {
                            VStack(spacing: 0) {
                                Button {
                                    path.append(AppRoute.passwordVerify(.editInfo))
                                } label: {
                                    SettingRowContentView(title: "회원정보 변경")
                                }
                                Divider().padding(.leading)

                                Button {
                                    path.append(AppRoute.passwordVerify(.changePassword))
                                } label: {
                                    SettingRowContentView(title: "사용자 비밀번호 설정")
                                }
                                Divider().padding(.leading)
                            }
                        }
                    }
                    
                    SettingSection(title: "약관 및 정책") {
                        VStack(spacing: 0) {
                            Button {
                                path.append(AppRoute.termOfUse)
                            } label: {
                                SettingRowContentView(title: "이용 약관")
                            }
                            Divider().padding(.leading)

                            Button {
                                path.append(AppRoute.privacyPolicy)
                            } label: {
                                SettingRowContentView(title: "개인정보 처리 방침")
                            }
                            Divider().padding(.leading)

                        }
                    }
                    
                    Spacer()
                    
                    FooterSectionView(
                        onWithdrawTap: {
                            path.append(AppRoute.withdrawal)
                        }
                    )
                }
                .padding()
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case.passwordVerify(let flow):
                    PersonalInfoPasswordVerifyView(
                        onBack: { path.removeLast() },
                        onGoNext: {
                            switch flow {
                            case .editInfo:
                                path.append(AppRoute.editInfo)
                            case .changePassword:
                                path.append(AppRoute.changePassword)
                            }
                        }
                    )
                case .editInfo:
                    PersonalInfoEditView(
                        onBack: { path.removeLast() },
                        onComplete: { path.removeLast(path.count) }
                    )
                case .changePassword:
                    ChangePasswordView(
                        onBack: { path.removeLast() },
                        onComplete: { path.removeLast(path.count)}
                    )
                case .termOfUse:
                    TermOfUserView(
                        onBack: { path.removeLast() }
                    )
                case .privacyPolicy:
                    PrivacyPolicyView(
                        onBack: { path.removeLast() }
                    )
                case .withdrawal:
                    WithdrawalView(
                        onBack: { path.removeLast() },
                        onComplete: { path.removeLast(path.count) }
                    )
                }
            }
            .task {
                guard userSession.isLoggedIn else { return }
                try? await userSession.refreshUser()
            }
        }
    }
}

private struct HealthKitDisclosureCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.subheadline)
                Text("Apple Health / HealthKit 연동")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Text("본 앱은 심박수 및 운동 기록을 Apple 건강(HealthKit)에서 읽어와 운동 화면에 표시합니다.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
    }
}


#Preview {
    MypageSettingView()
        .environmentObject(UserSessionStore())
}
