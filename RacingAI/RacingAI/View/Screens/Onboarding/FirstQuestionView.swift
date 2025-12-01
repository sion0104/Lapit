import SwiftUI

struct FirstQuestionView: View {
    @EnvironmentObject var bodyInfoStore: BodyInfoStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    ProgressView(value: 10, total: 90)
                        .tint(.black)
                    
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
                                maxLength: 5
                            )
                        }
                        
                        VStack(alignment: .leading) {
                            Text("몸무게")
                                .font(.callout)
                            
                            AppTextField (
                                text: $bodyInfoStore.weight,
                                placeholder: "몸무게를 입력해주세요",
                                keyboard: .decimalPad,
                                submitLabel: .next,
                                maxLength: 5
                            )
                        }
                        
                        VStack(alignment: .leading) {
                            Text("체지방률")
                                .font(.callout)
                            
                            AppTextField (
                                text: $bodyInfoStore.bodyFatRate,
                                placeholder: "체지방률을 입력해주세요.",
                                keyboard: .decimalPad,
                                submitLabel: .next,
                                maxLength: 5
                            )
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
                                title: option.rawValue,
                                isEnabled: true,
                                isLeading: true
                                ) {
                                bodyInfoStore.weightChange = option
                                }
                                .opacity(bodyInfoStore.weightChange == option ? 1 : 0.7)
                                .frame(maxHeight: .infinity, alignment: .leading)
                        }
                    }
                }
                
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            HStack {
                AppButton(title: "뒤로 가기", isEnabled: true) {
                    dismiss()
                }
                .frame(width: 122)
                AppButton(title: "다음 단계", isEnabled: true) {
                    // MARK: 다음 온보딩 뷰
                }
            }
            .padding()
        }
    }
}

#Preview {
    FirstQuestionView()
        .environmentObject(BodyInfoStore())
}
