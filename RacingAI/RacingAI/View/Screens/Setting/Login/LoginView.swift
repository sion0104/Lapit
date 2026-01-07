import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userSession: UserSessionStore
    @EnvironmentObject private var userInfoStore: UserInfoStore

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
            
            signupButton
                .padding(.bottom, 6)


            AppButton(
                title: isLoggingIn ? "로그인 중..." : "로그인",
                isEnabled: canSubmit && !isLoggingIn
            ) {
                login()
            }
            .buttonStyle(PrimaryButtonStyle())
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
                errorMessage = error.userMessage
            }
        }

    }
    
    private var signupButton: some View {
        HStack(spacing: 6) {
            Spacer()
            
            Text("계정이 없으신가요?")
                .font(.footnote)
                .foregroundStyle(Color("SecondaryFont"))
            
            NavigationLink {
                AuthenticationView()
                    .environmentObject(userInfoStore)
            } label: {
                Text("회원가입")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.footer)
                    .underline()
            }
            .disabled(isLoggingIn)
            .opacity(isLoggingIn ? 0.4 : 1)
            
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(UserSessionStore())
            .environmentObject(UserInfoStore())
    }
}
