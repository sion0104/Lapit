import SwiftUI

struct InformationView: View {
    
    enum Gender {
        case male
        case female
    }
     
    @State private var name: String = ""
    @State private var birth: String = ""
    @State private var gender: Gender? = nil
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("기초 정보를 작성해주세요")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 32)
                
                profileSection
                    .padding(.top, 16)
                nameSection
                    .padding(.top, 16)
                birthSection
                    .padding(.top, 16)
                genderSection
                    .padding(.top, 16)
                
                bottomButtons
                
            }
            .padding()
        }
    }
}

// MARK: - SubViews
private extension InformationView {
    
    var profileSection: some View {
        VStack(alignment: .leading) {
            Text("프로필 이미지")
                .font(.callout)
                .fontWeight(.medium)
            
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Button {
                    // 사진 등록 액션
                } label: {
                    Text("사진 등록")
                        .font(.footnote)
                        .foregroundStyle(.black)
                        .fontWeight(.semibold)
                    
                }
                .padding()
                Spacer()
            }
        }
    }
    
    var nameSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("이름")
                    .font(.callout)
                    .fontWeight(.medium)
                Text("*")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
                Spacer()
            }
            
            AppTextField(text: $name, placeholder: "사용하실 이름 또는 닉네임을 입력하세요", keyboard: .emailAddress, submitLabel: .next)
                .font(.footnote)
            
            Text("이름은 저장 후 변경 불가능합니다.")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        
    }
    
    var birthSection: some View {
        VStack (alignment: .leading){
            HStack {
                Text("생년월일")
                    .font(.callout)
                    .fontWeight(.medium)
                Text("*")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
            }
            AppTextField(text: $birth, placeholder: "YYYY.MM.DD", keyboard: .decimalPad, submitLabel: .done)
                .font(.footnote)
        }
    }
    
    var genderSection: some View {
        VStack (alignment: .leading){
            HStack {
                Text("성별")
                    .font(.callout)
                    .fontWeight(.medium)
                Text("*")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
            }
            HStack {
                GenderOptionView(title: "남성", isSelected: gender == .male) {
                    gender = .male
                }
                
                GenderOptionView(title: "여성", isSelected: gender == .female) {
                    gender = .female
                }
                .padding(.leading, 16)
            }
            
            Spacer()
        }
    }
    
    var bottomButtons: some View {
        VStack {
            Spacer()
            HStack {
                AppButton(title: "뒤로 가기", isEnabled: true) {
                    // 뒤로 가기 액션
                }
                .frame(width: 122, height: 48)
                AppButton(title: "다음 단계", isEnabled: true) {
                    // 다음 단계 액션
                }
            }
        }
    }
}

#Preview {
    InformationView()
}
