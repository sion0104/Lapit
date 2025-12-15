import SwiftUI

struct PersonalInfoPasswordVerifyView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var isVerified: Bool = false
    @State private var isVerifying: Bool = false
    
    @State private var goNext: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            
            passwordRow
            
            Spacer()
            
            AppButton(
                title: "다음 단계",
                isEnabled: isVerified
            ) {
                goNext = true
            }
        }
        .padding()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 5) {
                    Button {
                        dismiss()
                    } label: {
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
        .navigationDestination(isPresented: $goNext) {
//            PersonalInfoEditView()
        }
        .onChange(of: password) {
            errorMessage = nil
            isVerified = false
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("정보를 변경하려면\n본인 인증이 필요합니다")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("현재 계정의 비밀번호를 입력해 주세요.")
                .font(.callout)
                .foregroundStyle(Color("SecondaryFont"))
        }
    }
    
    private var passwordRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("비밀번호 확인")
                .font(.subheadline)
                .foregroundStyle(Color("SecondaryFont"))
            
            HStack(spacing: 10) {
                AppTextField(
                    text: $password,
                    placeholder: "비밀번호 입력",
                    isSecure: true,
                    keyboard: .default,
                    submitLabel: .done,
                    error: errorMessage) {
                        verifyPassword()
                    }
                
                Button {
                    verifyPassword()
                } label: {
                    Text(isVerifying ? "확인중" : "인증")
                        .fontWeight(.semibold)
                        .frame(width: 72, height: 52)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(password.isEmpty || isVerifying)
                .foregroundStyle((password.isEmpty || isVerifying) ? .gray : .primary)
            }
            
            if isVerified {
                Text("인증이 완료되었습니다.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func verifyPassword() {
        errorMessage = nil
        
        guard !password.isEmpty else {
            errorMessage = "비밀번호를 입력해주세요."
            isVerified = false
            return
        }
        
        isVerifying = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            defer { isVerifying = false}
            
            let success = (password == "1234")
            
            if success {
                isVerified = true
            } else {
                isVerified = false
                errorMessage = "비밀번호가 일치하지 않습니다."
            }
        }
    }
}

#Preview {
    PersonalInfoPasswordVerifyView()
}
