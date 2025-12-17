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
                                path.append(AppRoute.passwordVerify)
                            } label: {
                                SettingRowContentView(title: "회원정보 변경")
                            }
                            Divider().padding(.leading)
                        }
//                        SettingRowView(title: "사용자 비밀번호 설정")
//                        SettingRowView(title: "Push 알림 설정")
                    }
                    
                    SettingSection(title: "약관 및 정책") {
//                        SettingRowView(title: "이용 약관")
//                        SettingRowView(title: "개인정보 처리 방침")
                    }
                    
                    Spacer()
                    
                    FooterSectionView()
                }
                .padding()
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case.passwordVerify:
                    PersonalInfoPasswordVerifyView(
                        onBack: { path.removeLast() },
                        onGoNext: { path.append(AppRoute.editInfo) }
                    )
                case .editInfo:
                    PersonalInfoEditView(
                        onBack: { path.removeLast() },
                        onComplete: { path.removeLast(path.count) }
                    )
                }
            }
            .task {
                await userSession.fetchUserIfNeeded()
            }
        }
    }
}

#Preview {
    MypageSettingView()
        .environmentObject(UserSessionStore())
}
