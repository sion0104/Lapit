import SwiftUI

struct AppTextField: View {
    @Binding var text: String
    let placeholder: String
    
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var submitLabel: SubmitLabel = .done
    var error: String? = nil
    var onSubmit: (() -> Void)? = nil
    var maxLength: Int? = nil
    var isNumberOnly: Bool = false
    
    @FocusState private var isFocused: Bool
    @State private var revealSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
            
                inputField()
                    .keyboardType(keyboard)
                    .submitLabel(submitLabel)
                    .focused($isFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                if isSecure {
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { revealSecure.toggle() }
                    } label: {
                        Image(systemName: revealSecure ? "eye.slash" : "eye")
                            .imageScale(.medium)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel( revealSecure ? "비밀번호 숨기기" : "비밀번호 보기")
                }
                
                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.medium)
                            .foregroundStyle(.tertiary)
                    }
                    .accessibilityLabel("입력 내용 지우기")
                }
            }
            .modifier(TextFieldStyle(isFoucused: isFocused, isError: error != nil))
            
        }
        .onSubmit {
            onSubmit?()
        }
        .onChange(of: text) { _, newValue in
            var value = newValue
            
            if isNumberOnly {
                value = value.filter { $0.isNumber }
            }
            
            if let maxLength {
                value = String(value.prefix(maxLength))
            }
            
            if value != newValue {
                text = value
            }
        }
        .accessibilityElement(children: .contain)
    }
    
    @ViewBuilder
    private func inputField() -> some View {
        if isSecure && !revealSecure {
            SecureField(placeholder, text: $text)
                .textContentType(.password)
        } else {
            TextField(placeholder, text: $text)
        }
    }
}
