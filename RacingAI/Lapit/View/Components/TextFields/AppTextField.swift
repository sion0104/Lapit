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
    var isDate: Bool = false
    
    var isDatePickerPresented: Binding<Bool>? = nil
    
    var backgroundColor: Color = Color(.systemGray6)
    
    @FocusState private var isFocused: Bool
    @State private var revealSecure: Bool = false
    
    @State private var _showDatePicker: Bool = false
    @State private var selectedDate: Date = Date()
    
    private var showDatePicker: Bool {
        get { isDatePickerPresented?.wrappedValue ?? _showDatePicker }
        nonmutating set {
            if let b = isDatePickerPresented { b.wrappedValue = newValue }
            else { _showDatePicker = newValue }
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
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
            
            if isDate {
                Button {
                    isFocused = false
                    
                    if showDatePicker == false, let d = Self.parseDate(text) {
                        selectedDate = d
                    }
                    
                    withAnimation(.easeInOut(duration: 0.18)) { showDatePicker.toggle() }
                    
                    if let d = Self.parseDate(text) {
                        selectedDate = d
                    }
                } label: {
                    Image(systemName: "calendar")
                        .foregroundStyle(showDatePicker ? .primary : .secondary)
                        .font(.system(size: 16))
                        .background(
                            Circle()
                                .fill(showDatePicker
                                      ? Color.primary.opacity(0.08)
                                      : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(showDatePicker ? "날짜 선택 숨기기" : "날짜 선택 보기")                    }
            
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
            .modifier(
                TextFieldStyle(
                    isFoucused: isFocused,
                    isError: error != nil,
                    backgroundColor: backgroundColor
                )
            )
            .overlay(alignment: .top) {
               if isDate && showDatePicker {
                   datePickerOverlay
                       .frame(maxWidth: .infinity, alignment: .center)
                       .offset(y: 56)
                       .zIndex(999)
               }
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
    
    private var datePickerOverlay: some View {
        VStack(spacing: 10) {
            DatePicker(
                "",
                selection: $selectedDate,
                in: ...Date(),
                displayedComponents: [.date]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .onChange(of: selectedDate) { _, newValue in
                text = Self.formatDate(newValue)
            }
        }
        .padding(12)
       .background(
           RoundedRectangle(cornerRadius: 14, style: .continuous)
               .fill(Color(.systemBackground))
       )
       .overlay(
           RoundedRectangle(cornerRadius: 14, style: .continuous)
               .stroke(Color.primary.opacity(0.08), lineWidth: 0)
       )
        .shadow(color: Color.black.opacity(0.1), radius: 30, x: 0, y: 6)
        .onAppear {
            if let d = Self.parseDate(text) { selectedDate = d }
        }
    }
    
    @ViewBuilder
    private func inputField() -> some View {
        if isSecure && !revealSecure {
            SecureField(placeholder, text: $text)
                .textContentType(.password)
        } else {
            TextField(placeholder, text: $text)
                .disabled(isDate)
        }
    }
}

private extension AppTextField {
    static func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy.MM.dd"
        return f.string(from: date)
    }
    
    static func parseDate(_ text: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.calendar = Calendar(identifier: .gregorian)
        f.dateFormat = "yyyy.MM.dd"
        return f.date(from: text)
    }
}

