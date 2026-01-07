import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var store: UserInfoStore
    
    @State private var userId: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var userIdError: String? = nil
    @State private var passwordError: String? = nil
    
    @State private var isCheckingId: Bool = false
    @State private var canNavigate: Bool = false
    
    private let checkDuplicateIdAPI: CheckDuplicateIdAPIProtocol = CheckDuplicateIDAPI()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("AI 운동 플래너")
                .padding(.top, 32)
            
            Text("사용자 인증")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack (alignment: .leading){
                Text("아이디")
                    .fontWeight(.medium)
                AppTextField(text: $userId, placeholder: "아이디를 입력해 주세요.", keyboard: .emailAddress, submitLabel: .next, error: userIdError)
            }
            .padding(.top, 32)
            
            VStack(alignment: .leading){
                Text("비밀번호")
                    .fontWeight(.medium)
                AppTextField(text: $password, placeholder: "비밀번호를 입력해 주세요.", isSecure: true, submitLabel: .next)
            }
            .padding(.top, 16)
            
            VStack(alignment: .leading){
                Text("비밀번호 확인")
                    .fontWeight(.medium)
                AppTextField(text: $confirmPassword, placeholder: "비밀번호를 다시 입력해 주세요.", isSecure: true, submitLabel: .done, error: passwordError)
            }
            .padding(.top, 16)
            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $canNavigate) {
            InformationView()
                .environmentObject(store)
        }
        .safeAreaInset(edge: .bottom) {
            AppButton(title: "다음 단계", isEnabled: isFormInputFilled && !isCheckingId) {
                Task {
                    await validateAndProceed()
                }
            }
            .padding()
            .buttonStyle(PrimaryButtonStyle())
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var isFormInputFilled: Bool {
        !userId.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }
}

extension AuthenticationView {
    private func validateLocalUserId() -> Bool {
        guard (4...16).contains(userId.count) else {
            userIdError = "아이디는 4~16자의 영문 소문자와 숫자만 사용할 수 있습니다."
            return false
        }
        
        let pattern = "^[a-z][a-z0-9]{3,15}$"
        if userId.range(of: pattern, options: .regularExpression) == nil {
            userIdError = "아이디는 영문 소문자로 시작해야 하며, 영문 소문자와 숫자만 사용할 수 있습니다."
            return false
        }
        
        userIdError = nil
        return true
    }
    
    private func validatePasswords() -> Bool {
        guard !password.isEmpty, !confirmPassword.isEmpty else {
            passwordError = "비밀번호와 비밀번호 확인을 모두 입력해 주세요."
            return false
        }
        
        guard password == confirmPassword else {
            passwordError = "비밀번호와 비밀번호 확인 값이 일치하지 않습니다."
            return false
        }
        
        passwordError = nil
        return true
    }
    
}

extension AuthenticationView {
    private func validateAndProceed() async {
        userIdError = nil
        passwordError = nil
        
        guard validateLocalUserId() else { return }
        guard validatePasswords() else { return }
        
        isCheckingId = true
        defer { isCheckingId = false }
        
        do {
            let isAvailable = try await checkDuplicateIdAPI.fetchCheckDuplicateID(username: userId)
            
            if isAvailable {
                store.id = userId
                store.password = password
                canNavigate = true
            } else {
                userIdError = "이미 사용 중인 아이디입니다."
            }
        } catch {
            userIdError = "네트워크 오류가 발생했습니다. 다시 시도해 주세요."
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(UserInfoStore())
}
