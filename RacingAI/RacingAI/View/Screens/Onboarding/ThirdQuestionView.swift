import SwiftUI

struct ThirdQuestionView: View {
    @EnvironmentObject var bodyInfoStore: BodyInfoStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var canGoNext = false
    
    private var isNextEnabled: Bool {
        bodyInfoStore.weeklyExerciseFrequency != nil &&
        bodyInfoStore.preferredExerciseTime != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    ProgressView(value: 30, total: 90)
                        .tint(.black)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("평소 운동 습관을 알려주세요")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("훈련 빈도와 강도에 따라 맞춤 플랜을 짜드립니다")
                            .font(.callout)
                    }
                }
                .padding(.bottom, 30)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("일주일에 몇 번 운동하시나요?")
                        .font(.callout)
                        .fontWeight(.medium)
                    
                    let columns = [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ]
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(ExerciseFrequency.allCases) { frequency in
                            AppButton(
                                title: frequency.rawValue,
                                isEnabled: true) {
                                    bodyInfoStore.weeklyExerciseFrequency = frequency
                                }
                                .font(.callout)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .opacity(bodyInfoStore.weeklyExerciseFrequency == frequency ? 1.0 : 0.7)
                        }
                    }
                }
                
                if bodyInfoStore.weeklyExerciseFrequency != nil {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("주로 운동하는 시간대를 알려주세요")
                            .font(.callout)
                            .fontWeight(.medium)
                            .padding(.top, 20)
                        
                        VStack(spacing: 10) {
                            ForEach(ExerciseTime.allCases) { time in
                                AppButton(
                                    title: String("\(time.emoji) \(time.title) \(time.detail)"),
                                    isEnabled: true,
                                    isLeading: true) {
                                        bodyInfoStore.preferredExerciseTime = time
                                    }
                                    .font(.callout)
                                    .fontWeight(.medium)
                                    .opacity(bodyInfoStore.preferredExerciseTime == time ? 1.0 : 0.7)

                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationDestination(isPresented: $canGoNext) {
            // MARK: 다음 온보딩 화면
        }
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            BottomBar(
                leftTitle: "뒤로 가기",
                rightTitle: "다음 단계",
                isLeftEnabled: true,
                isRightEnabled: isNextEnabled,
                leftAction: {
                    dismiss()
                }, rightAction: {
                    guard isNextEnabled else { return }
                    canGoNext = true
                })
        }
    }
}

#Preview {
    ThirdQuestionView()
        .environmentObject(BodyInfoStore())
}
