import SwiftUI
import PhotosUI

struct PersonalInfoEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userSession: UserSessionStore

    let onComplete: () -> Void

    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImageData: Data?

    @State private var id: String = ""   // 변경 불가
    @State private var name: String = ""
    @State private var birth: String = ""
    @State private var gender: InformationView.Gender? = nil

    @State private var birthError: String? = nil

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !birth.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        birthError == nil &&
        gender != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            profileSection

            emailSection

            Divider().padding(.vertical, 4)

            nameSection
            birthSection
            genderSection

            Spacer()

        }
        .padding()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 5) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.black)
                    }

                    Text("개인정보 변경")
                        .font(.title3)
                        .foregroundStyle(Color("Chevron"))
                        .fontWeight(.medium)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            AppButton(
                title: "저장",
                isEnabled: canSave
            ) {
                onComplete()
                dismiss()
            }
            .padding()
        }
        .onAppear {
            if let user = userSession.user {
                id = user.id
                name = user.name
                birth = user.birthDate.replacingOccurrences(of: "-", with: ".")
                if user.gender.uppercased().contains("M") {
                    gender = .male
                } else if user.gender.uppercased().contains("F") {
                    gender = .female
                }
            }
        }
        .onChange(of: selectedItem) { _, newValue in
            Task {
                guard let newValue else { return }
                if let data = try? await newValue.loadTransferable(type: Data.self) {
                    await MainActor.run { profileImageData = data }
                }
            }
        }
    }
}

// MARK: - UI Sections
private extension PersonalInfoEditView {

    var profileSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("프로필 이미지")
                .font(.callout)
                .fontWeight(.medium)

            HStack(spacing: 16) {
                ZStack {
                    if let data = profileImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                            .clipped()
                    } else if let url = URL(string: userSession.user?.profileImgUrl ?? "") {
                        AsyncImage(url: url) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Circle().fill(Color(.systemGray5))
                        }
                        .frame(width: 72, height: 72)
                        .clipShape(Circle())
                        .clipped()
                    } else {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 72, height: 72)
                    }
                }

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Text("프로필 사진 수정")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .underline()
                }
            }
        }
    }

    var emailSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("아이디")
                .font(.callout)
                .fontWeight(.medium)

                AppTextField(
                    text: .constant(id),
                    placeholder: "아이디",
                    keyboard: .default,
                    submitLabel: .done
                )
                .disabled(true)


            Text("아이디 변경할 수 없습니다.")
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }

    var nameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("이름")
                .font(.callout)
                .fontWeight(.medium)

            AppTextField(
                text: $name,
                placeholder: "사용하실 이름 또는 닉네임을 입력하세요",
                keyboard: .default,
                submitLabel: .next
            )
            .font(.footnote)
        }
    }

    var birthSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("생년월일")
                .font(.callout)
                .fontWeight(.medium)

            AppTextField(
                text: $birth,
                placeholder: "YYYY.MM.DD",
                keyboard: .numberPad,
                submitLabel: .done,
                error: birthError,
                maxLength: 10,
                isNumberOnly: false
            )
            .font(.footnote)
            .onChange(of: birth) { _, newValue in
                let formatted = formatBirthInput(newValue)
                if formatted != newValue {
                    birth = formatted
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
        VStack(alignment: .leading, spacing: 10) {
            Text("성별")
                .font(.callout)
                .fontWeight(.medium)

            HStack {
                GenderOptionView(title: "남성", isSelected: gender == .male) {
                    gender = .male
                }

                GenderOptionView(title: "여성", isSelected: gender == .female) {
                    gender = .female
                }
                .padding(.leading, 16)
            }
        }
    }
}

// MARK: - Birth Helpers (InformationView와 동일 로직)
private extension PersonalInfoEditView {
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
              let month = Int(parts[1]) else { return nil }

        if !(1900...2100).contains(year) { return "올바른 연도를 입력해주세요." }
        if !(1...12).contains(month) { return "올바른 월을 입력해주세요." }

        if parts.count >= 3, let day = Int(parts[2]), day > 31 {
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

        guard (1900...2100).contains(year) else { return "올바른 년도를 입력해주세요." }
        guard (1...12).contains(month) else { return "올바른 월을 입력해주세요." }
        guard (1...31).contains(day) else { return "올바른 일을 입력해주세요." }

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

        if date > Date() { return "생년월일은 미래일 수 없습니다." }
        return nil
    }
}

#Preview {
    PersonalInfoEditView(onComplete: {})
        .environmentObject(UserSessionStore())
}
