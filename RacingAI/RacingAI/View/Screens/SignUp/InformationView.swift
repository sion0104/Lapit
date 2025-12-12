import SwiftUI
import PhotosUI

struct InformationView: View {
    
    enum Gender {
        case male
        case female
    }
     
    @EnvironmentObject var store: UserInfoStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedItem: PhotosPickerItem?
    
    @State private var showTermsSheet = false
    @State private var showValidationAlert = false
    
    @State private var birthError: String? = nil
    
    private var canGoNext: Bool {
        !store.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !store.birth.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        birthError == nil &&
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
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom, content: {
            BottomBar(
                leftTitle: "뒤로 가기",
                rightTitle: "다음 단계",
                isLeftEnabled: true,
                isRightEnabled: canGoNext,
                leftAction: {
                    dismiss()
                }, rightAction: {
                    if canGoNext {
                        showTermsSheet = true
                    } else {
                        showValidationAlert = true
                    }
                })
        })
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
            AppTextField(
                text: $store.birth,
                placeholder: "YYYY.MM.DD",
                keyboard: .numberPad,
                submitLabel: .done,
                error: birthError,
                maxLength: 10,
                isNumberOnly: false
            )
                .font(.footnote)
                .onChange(of: store.birth) { _, newValue in
                    let formatted = formatBirthInput(newValue)
                    
                    if formatted != newValue {
                        store.birth = formatted
                        return
                    }
                    birthError = validateBirthIntermediate(formatted)
                    
                    if formatted.count == 10, birthError == nil {
                        birthError = validateBirthFinal(formatted)
                    }
                }
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
}

private extension InformationView {
    func formatBirthInput(_ input: String) -> String {
        let digits = input.filter { $0.isNumber }
        
        let limited = String(digits.prefix(8))
        
        var result = ""
        for (i, ch) in limited.enumerated() {
            if i == 4 || i == 6 { result.append(".") }
            result.append(ch)
        }
        return result
    }
    
    func validateBirthIntermediate(_ formatted: String) -> String? {
        let parts = formatted.split(separator: ".").map(String.init)
        
        guard parts.count >= 2,
              let year = Int(parts[0]),
              let month = Int(parts[1]) else {
            return nil
        }
        
        if !(1900...2100).contains(year) {
            return "올바른 연도를 입력해주세요."
        }
        
        if !(1...12).contains(month) {
            return "올바른 월을 입력해주세요."
        }
        
        if parts.count >= 3,
           let day = Int(parts[2]),
           day > 31 {
            return "올바른 일을 입력해주세요."
        }
        
        return nil
    }
    
    func validateBirthFinal(_ formatted: String) -> String? {
        let pattern = #"^\d{4}\.\d{2}\.\d{2}$"#
        guard formatted.range(of: pattern, options: .regularExpression) != nil else {
            return "생년월일 형식이 올바르지 않습니다. (YYYY.MM.DD)"
        }
        
        let parts = formatted.split(separator: ".").map(String.init)
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]) else {
            return "생년월일을 다시 확인해 주세요."
        }
        
        guard (1900...2025).contains(year) else {
            return "올바른 년도를 입력해주세요."
        }
        guard (1...12).contains(month) else {
            return "올바른 월을 입력해주세요."
        }
        guard (1...31).contains(day) else {
            return "올바른 일을 입력해주세요."
        }
        
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        
        let calendar = Calendar.current
        guard let date = calendar.date(from: comps),
              calendar.component(.year, from: date) == year,
              calendar.component(.month, from: date) == month,
              calendar.component(.day, from: date) == day else {
            return "존재하지 않는 날짜입니다."
        }
        
        if date > Date() {
            return "생년월일은 미래일 수 없습니다."
        }
        
        return nil
                
    }
}

#Preview {
    InformationView()
        .environmentObject(UserInfoStore())
}
