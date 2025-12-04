import SwiftUI

struct SixthQuestionView: View {
    @EnvironmentObject var bodyInfoStore: BodyInfoStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var canGoNext = false
    
    private var isNextEnabled: Bool {
        bodyInfoStore.affiliation != nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    ProgressView(value: 50, total: 90)
                        .tint(.black)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("현재 소속을 알려주세요")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .padding(.bottom, 30)
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(spacing: 10) {
                        ForEach(Affiliation.allCases) { affiliation in
                            AppButton(
                                title: affiliation.rawValue,
                                isEnabled: true,
                                isLeading: true
                            ) {
                                    bodyInfoStore.affiliation = affiliation
                                }
                                .font(.callout)
                                .fontWeight(.medium)
                                .opacity(bodyInfoStore.affiliation == affiliation ? 1.0 : 0.7)

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
                    }
                )
            }
            .navigationDestination(isPresented: $canGoNext) {
                // MARK: 다음 인보딩 화면
    //            FourthQuestionView()
    //                .environmentObject(bodyInfoStore)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    SixthQuestionView()
        .environmentObject(BodyInfoStore())
}
