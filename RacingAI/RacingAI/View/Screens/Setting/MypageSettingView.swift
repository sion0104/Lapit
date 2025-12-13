import SwiftUI

struct MypageSettingView: View {
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(alignment:.leading, spacing: 20) {
                    Text("마이페이지 및 설정")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    ProfileSectionView()
                    
                    SettingSection(title: "설정") {
                        SettingRowView(title: "회원정보 변경")
                        SettingRowView(title: "사용자 비밀번호 설정")
                        SettingRowView(title: "Push 알림 설정")
                    }
                    
                    SettingSection(title: "약관 및 정책") {
                        SettingRowView(title: "이용 약관")
                        SettingRowView(title: "개인정보 처리 방침")
                    }
                    
                    Spacer()
                    
                    FooterSectionView()
                }
            }
        }
        .padding()
    }
}

#Preview {
    MypageSettingView()
}
