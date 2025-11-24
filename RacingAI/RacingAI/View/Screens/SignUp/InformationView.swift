import SwiftUI
import PhotosUI

struct InformationView: View {
    
    enum Gender {
        case male
        case female
    }
     
    @EnvironmentObject var store: UserInfoStore
    
    @State private var selectedItem: PhotosPickerItem?
    
    @State private var showTermsSheet = false
    @State private var showValidationAlert = false
    
    private var canGoNext: Bool {
        !store.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !store.birth.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        store.gender != nil
    }
    
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
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showTermsSheet) {
            TermsView()
                .environmentObject(store)
                .presentationDetents([.medium, .large])
        }
        .alert("입력 확인", isPresented: $showValidationAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("이름, 생년월일, 성별을 모두 입력/선택해야 다음 단계로 넘어갈 수 있어요.")
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
                    if let data = store.profileImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                            .clipped()
                    } else {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 72, height: 72)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(.white.opacity(0.7))
                            )
                    }
                }
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images
                ) {
                    Text("사진 등록")
                        .font(.footnote)
                        .foregroundStyle(.black)
                        .fontWeight(.semibold)
                }
                .onChange(of: selectedItem) { oldValue, newValue in
                    Task {
                        guard let newValue else { return }
                        if let data = try? await newValue.loadTransferable(type: Data.self) {
                            await MainActor.run {
                                store.profileImageData = data
                            }
                        }
                    }
                }
                .padding()
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
            
            AppTextField(text: $store.name, placeholder: "사용하실 이름 또는 닉네임을 입력하세요", keyboard: .emailAddress, submitLabel: .next)
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
            AppTextField(text: $store.birth, placeholder: "YYYY.MM.DD", keyboard: .decimalPad, submitLabel: .done)
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
                GenderOptionView(title: "남성", isSelected: store.gender == .male) {
                    store.gender = .male
                }
                
                GenderOptionView(title: "여성", isSelected: store.gender == .female) {
                    store.gender = .female
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
                    if canGoNext {
                        showTermsSheet = true
                    } else {
                        showValidationAlert = true
                    }
                }
            }
        }
    }
}

#Preview {
    InformationView()
        .environmentObject(UserInfoStore())
}
