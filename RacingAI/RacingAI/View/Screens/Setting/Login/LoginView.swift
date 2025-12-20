import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userSession: UserSessionStore

    @State private var userId: String = ""
    @State private var password: String = ""

    @State private var errorMessage: String? = nil
    @State private var isLoggingIn: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            idRow
            passwordRow

            Spacer()

            AppButton(
                title: isLoggingIn ? "로그인 중..." : "로그인",
                isEnabled: canSubmit && !isLoggingIn
            ) {
                login()
            }
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
                    .disabled(isLoggingIn)
                    .opacity(isLoggingIn ? 0.4 : 1)

                    Text("로그인")
                        .font(.title3)
                        .foregroundStyle(Color("Chevron"))
                        .fontWeight(.medium)
                }
            }
        }
        .onChange(of: userId) { oldValue, newValue in
            clearError()
        }
        .onChange(of: password) { oldValue, newValue in
            clearError()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("서비스 이용을 위해\n로그인이 필요합니다")
                .font(.title3)
                .fontWeight(.medium)

            Text("아이디와 비밀번호를 입력해 주세요.")
                .font(.callout)
                .foregroundStyle(Color("SecondaryFont"))
        }
    }

    private var idRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("아이디")
                .font(.subheadline)
                .foregroundStyle(Color("SecondaryFont"))

            AppTextField(
                text: $userId,
                placeholder: "아이디 입력",
                isSecure: false,
                keyboard: .default,
                submitLabel: .next,
                error: nil
            ) {
                // next로 넘기고 싶으면 FocusState로 확장 가능
            }
        }
    }

    private var passwordRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("비밀번호")
                .font(.subheadline)
                .foregroundStyle(Color("SecondaryFont"))

            AppTextField(
                text: $password,
                placeholder: "비밀번호 입력",
                isSecure: true,
                keyboard: .default,
                submitLabel: .done,
                error: errorMessage
            ) {
                login()
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }

    private var canSubmit: Bool {
        !userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.isEmpty
    }

    private func clearError() {
        errorMessage = nil
    }

    private func login() {
        clearError()

        guard canSubmit else {
            errorMessage = "아이디와 비밀번호를 입력해주세요."
            return
        }

        isLoggingIn = true

        Task {
            defer { isLoggingIn = false }
            
            do {
                
                try await userSession.login(
                    username: userId,
                    password: password
                )
                
                dismiss()
            } catch {
                errorMessage = describeAPIError(error)
            }
        }

    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
