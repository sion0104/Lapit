import SwiftUI

struct FifthQuestionView: View {
    @EnvironmentObject var bodyInfoStore: BodyInfoStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var canGoNext = false
    
    private var isNextEnabled: Bool {
        bodyInfoStore.seasonGoal != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    ProgressView(value: 50, total: 90)
                        .tint(.black)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("이번 시즌의 목표는 무엇인가요?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("목표에 맞는 훈련주기와 강도를 설정합니다")
                            .font(.callout)
                    }
                }
                .padding(.bottom, 30)
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(spacing: 10) {
                        ForEach(SeasonGoal.allCases) { goal in
                            AppButton(
                                title: goal.rawValue,
                                isEnabled: true,
                                isLeading: true
                            ) {
                                    bodyInfoStore.seasonGoal = goal
                                }
                                .font(.callout)
                                .fontWeight(.medium)
                                .opacity(bodyInfoStore.seasonGoal == goal ? 1.0 : 0.7)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationDestination(isPresented: $canGoNext) {
            FourthQuestionView()
                .environmentObject(bodyInfoStore)
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
    FifthQuestionView()
        .environmentObject(BodyInfoStore())
}
