import SwiftUI

struct FourthQuestionView: View {
    @EnvironmentObject var bodyInfoStore: BodyInfoStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var canGoNext = false
    
    private var isNextEnabled: Bool {
        bodyInfoStore.ridingExperience != nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    ProgressView(value: 4, total: 5)
                        .tint(Color("MainColor"))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("라이딩 경력을 알려주세요")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .padding(.bottom, 30)
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(spacing: 10) {
                        ForEach(RidingExperience.allCases) { experience in
                            AppButton(
                                title: experience.title,
                                isEnabled: true,
                                isLeading: true
                            ) {
                                bodyInfoStore.ridingExperience = experience
                                }
                            .buttonStyle(SecondaryButtonStyle())
                                .font(.callout)
                                .fontWeight(.medium)
                                .opacity(bodyInfoStore.ridingExperience == experience ? 1.0 : 0.7)

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
