import SwiftUI

struct ChangePasswordView: View {
    let onBack: () -> Void
    let onComplete: () -> Void

    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String? = nil
    @State private var isSaving: Bool = false

    private var canSubmit: Bool {
        !newPassword.isEmpty && !confirmPassword.isEmpty && newPassword == confirmPassword
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            VStack(alignment: .leading, spacing: 10) {
                Text("새 비밀번호")
                    .font(.callout)

                AppTextField(
                    text: $newPassword,
                    placeholder: "6자리 이상 영문, 숫자",
                    isSecure: true,
                    submitLabel: .next,
                    error: nil
                )
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("비밀번호 확인")
                    .font(.callout)

                AppTextField(
                    text: $confirmPassword,
                    placeholder: "새 비밀번호를 한 번 더 입력하세요",
                    isSecure: true,
                    submitLabel: .done,
                    error: errorMessage
                ) {
                    save()
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            
            Spacer()
            
            AppButton(
                title: isSaving ? "비밀번호 변경 중..." : "비밀번호 변경",
                isEnabled: canSubmit && !isSaving
            ) {
                save()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom, content: {
           
        })
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 5) {
                    Button { onBack() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.black)
                    }

                    Text("비밀번호 변경")
                        .font(.title3)
                        .foregroundStyle(Color("Chevron"))
                        .fontWeight(.medium)
                }
            }
        }
        .onChange(of: newPassword) { _, _ in errorMessage = nil }
        .onChange(of: confirmPassword) { _, _ in errorMessage = nil }
    }

    private func save() {
        errorMessage = nil

        guard !newPassword.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "비밀번호를 입력해주세요."
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "비밀번호가 일치하지 않습니다."
            return
        }

        isSaving = true
        defer { isSaving = false }

        // TODO: 비밀번호 변경 API 붙일 자리
        onComplete()
    }
}

#Preview {
    ChangePasswordView(onBack: {}, onComplete: {})
}
