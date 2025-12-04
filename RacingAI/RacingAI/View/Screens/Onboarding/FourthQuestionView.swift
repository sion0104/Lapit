import SwiftUI

struct FourthQuestionView: View {
    @EnvironmentObject var bodyInfoStore: BodyInfoStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var canGoNext = false
    
    private var isNextEnabled: Bool {
        bodyInfoStore.preferredTraning != nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    ProgressView(value: 40, total: 90)
                        .tint(.black)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("선호하는 훈련은 무엇인가요?")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .padding(.bottom, 30)
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(spacing: 10) {
                        ForEach(Training.allCases) { training in
                            AppButton(
                                title: training.rawValue,
                                isEnabled: true,
                                isLeading: true
                            ) {
                                    bodyInfoStore.preferredTraning = training
                                }
                                .font(.callout)
                                .fontWeight(.medium)
                                .opacity(bodyInfoStore.preferredTraning == training ? 1.0 : 0.7)

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
                    }, rightAction: {
                        guard isNextEnabled else { return }
                        canGoNext = true
                    })
            }
            .navigationDestination(isPresented: $canGoNext) {
                FifthQuestionView()
                    .environmentObject(bodyInfoStore)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    FourthQuestionView()
        .environmentObject(BodyInfoStore())
}
