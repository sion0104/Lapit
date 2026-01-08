import SwiftUI

struct MypageSettingView: View {
    @EnvironmentObject private var userSession: UserSessionStore
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path){
            ScrollView {
                VStack(alignment:.leading, spacing: 20) {
                    Text("마이페이지 및 설정")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    ProfileSectionView()
                    
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
                guard userSession.user == nil else { return }
                await userSession.fetchUserIfNeeded()
            }
        }
    }
}

#Preview {
    MypageSettingView()
        .environmentObject(UserSessionStore())
}
