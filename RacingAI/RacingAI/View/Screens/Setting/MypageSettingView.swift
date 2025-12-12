import SwiftUI

struct MypageSettingView: View {
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(alignment:.leading, spacing: 30) {
                    Text("마이페이지 및 설정")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    HStack {
                        Circle()
                            .size(width: 48, height: 48)
                        
                        VStack(alignment: .leading, spacing: 10){
                            Text("이름")
                                .font(.callout)
                            
                            Text("아이디")
                                .font(.caption)
                            
                        }
                        
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("설정")
                            .font(.subheadline)
                            .foregroundStyle(Color("SecondaryFont"))
                        
//                        List
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    MypageSettingView()
}
