import SwiftUI

struct FifthQuestionView: View {
    @EnvironmentObject var bodyInfoStore: BodyInfoStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var canGoNext = false
    
    private var isNextEnabled: Bool {
        bodyInfoStore.todayCondition != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    ProgressView(value: 5, total: 5)
                        .tint(Color("MainColor"))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("오늘 컨디션은 어떤가요")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .padding(.bottom, 30)
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(spacing: 10) {
                        ForEach(TodayCondition.allCases) { condition in
                            AppButton(
                                title: condition.title,
                                isEnabled: true,
                                isLeading: true
                            ) {
                                bodyInfoStore.todayCondition = condition
                                }
                            .buttonStyle(SecondaryButtonStyle())
                                .font(.callout)
                                .fontWeight(.medium)
                                .opacity(bodyInfoStore.todayCondition == condition ? 1.0 : 0.7)
                        }
                    }
                }
            }
            .padding()
            .safeAreaInset(edge: .bottom) {
                AppButton(
                    title: "설문 완료",
                    isEnabled: isNextEnabled) {
                        guard isNextEnabled else { return }
                        canGoNext = true
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding()
            }
            .navigationDestination(isPresented: $canGoNext) {
                CompleteView()
                    .environmentObject(bodyInfoStore)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    FifthQuestionView()
        .environmentObject(BodyInfoStore())
}
