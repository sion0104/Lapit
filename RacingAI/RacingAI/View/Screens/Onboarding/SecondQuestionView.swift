import SwiftUI

struct SecondQuestionView: View {
    @EnvironmentObject var bodyInfoStore: BodyInfoStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var cangoNext = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    ProgressView(value: 2, total: 5)
                        .tint(Color("MainColor"))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("주로 누구와 훈련하나요?")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.bottom, 20)
                }
                
               
                HStack(spacing: 16) {
                    ForEach(TrainingPartner.allCases) { option in
                        Button {
                            bodyInfoStore.trainingPartner = option
                        } label: {
                            VStack {
                                Spacer()
                                Text(option.title)
                                    .font(.callout)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.black)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, minHeight: 70)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.systemGray5))
                            )
                            .opacity(bodyInfoStore.trainingPartner == option ? 1.0 : 0.7)
                        }
                    }
                }
                Spacer(minLength: 6)
            }
            .padding()
            .safeAreaInset(edge: .bottom) {
                BottomBar(
                    leftTitle: "뒤로 가기",
                    rightTitle: "다음 단계",
                    isLeftEnabled: true,
                    isRightEnabled: bodyInfoStore.trainingPartner != nil, leftAction: {
                        dismiss()
                    },
                    rightAction: {
                        cangoNext = true
                    }
                )
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $cangoNext, destination: {
                ThirdQuestionView()
                    .environmentObject(bodyInfoStore)
            })
        }
    }
}

#Preview {
    SecondQuestionView()
        .environmentObject(BodyInfoStore())
}
