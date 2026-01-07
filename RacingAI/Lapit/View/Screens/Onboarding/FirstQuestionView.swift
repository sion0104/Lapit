import SwiftUI

struct FirstQuestionView: View {
    @EnvironmentObject var bodyInfoStore: BodyInfoStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var canNavigate: Bool = false
    
    private var isNextEnabled: Bool {
        heightValue != nil &&
        weightValue != nil &&
        !bodyInfoStore.bmi.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        bodyInfoStore.weightChange != nil
    }

    
    private var heightValue: Double? {
        Double(bodyInfoStore.height)
    }

    private var weightValue: Double? {
        Double(bodyInfoStore.weight)
    }

    private var heightError: String? {
        if bodyInfoStore.height.isEmpty { return nil }
        return heightValue == nil ? "숫자(예: 170 또는 170.5)만 입력해주세요." : nil
    }

    private var weightError: String? {
        if bodyInfoStore.weight.isEmpty { return nil }
        return weightValue == nil ? "숫자(예: 70 또는 70.2)만 입력해주세요." : nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    ProgressView(value: 1, total: 5)
                        .tint(Color("MainColor"))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("현재 몸 상태는 어떤가요?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("정확한 훈련 강도와 회복 일정을 설정합니다")
                            .font(.callout)
                    }
                    .padding(.bottom, 30)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("신체 정보")
                        .font(.callout)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading) {
                            Text("키")
                                .font(.callout)
                            
                            AppTextField (
                                text: $bodyInfoStore.height,
                                placeholder: "키를 입력해주세요",
                                keyboard: .decimalPad,
                                submitLabel: .next,
                                error: heightError,
                                maxLength: 5
                            )
                            .onChange(of: bodyInfoStore.height) { _, _ in
                                bodyInfoStore.updateBMI()
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("몸무게")
                                .font(.callout)
                            
                            AppTextField (
                                text: $bodyInfoStore.weight,
                                placeholder: "몸무게를 입력해주세요",
                                keyboard: .decimalPad,
                                submitLabel: .next,
                                error: weightError,
                                maxLength: 5
                            )
                            .onChange(of: bodyInfoStore.weight) { _, _ in
                                bodyInfoStore.updateBMI()
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("BMI")
                                .font(.callout)
                            
                            AppTextField (
                                text: $bodyInfoStore.bmi,
                                placeholder: "자동 계산 됩니다.",
                                keyboard: .decimalPad,
                                submitLabel: .next,
                                maxLength: 5
                            )
                            .disabled(true)
                            .opacity(0.8)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("Background"))
                    )
                    .padding(.bottom, 30)

                }
                VStack(alignment: .leading) {
                    Text("최근 3개월 간 체중변화")
                        .font(.callout)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(WeightChange.allCases) { option in
                            AppButton(
                                title: option.title,
                                isEnabled: true,
                                isLeading: true
                                ) {
                                bodyInfoStore.weightChange = option
                                }
                                .opacity(bodyInfoStore.weightChange == option ? 1 : 0.7)
                                .frame(maxHeight: .infinity, alignment: .leading)
                                .buttonStyle(SecondaryButtonStyle())
                        }
                    }
                }
                
            }
            .padding()
            .safeAreaInset(edge: .bottom) {
                BottomBar(
                    leftTitle: "뒤로 가기",
                    rightTitle: "다음 단계",
                    isLeftEnabled: true,
                    isRightEnabled: isNextEnabled,
                    leftAction: {
                        dismiss()
                    },
                    rightAction: {
                        guard isNextEnabled else { return }
                        canNavigate = true
                    }
                )
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $canNavigate, destination: {
                SecondQuestionView()
                    .environmentObject(bodyInfoStore)
            })
            .onChange(of: bodyInfoStore.height) { _, newValue in
                let sanitized = newValue.sanitizedDecimal(maxFractionDigits: 1)
                if sanitized != newValue { bodyInfoStore.height = sanitized }
            }

            .onChange(of: bodyInfoStore.weight) { _, newValue in
                let sanitized = newValue.sanitizedDecimal(maxFractionDigits: 1)
                if sanitized != newValue { bodyInfoStore.weight = sanitized }
            }

        }
    }
}

extension String {
    func sanitizedDecimal(maxFractionDigits: Int? = nil) -> String {
        var s = self.replacingOccurrences(of: ",", with: ".")
        s = s.filter { $0.isNumber || $0 == "." }

        if let firstDot = s.firstIndex(of: ".") {
            let after = s.index(after: firstDot)
            let beforePart = s[..<after]
            let rest = s[after...].replacingOccurrences(of: ".", with: "")
            s = String(beforePart) + rest
        }

        if let maxFractionDigits,
           let dotIndex = s.firstIndex(of: ".") {
            let afterDot = s.index(after: dotIndex)
            let intPart = s[..<afterDot]
            let fracPart = s[afterDot...]
            s = String(intPart) + String(fracPart.prefix(maxFractionDigits))
        }

        return s
    }
}


#Preview {
    FirstQuestionView()
        .environmentObject(BodyInfoStore())
}
