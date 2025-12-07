import SwiftUI

struct SeventhQuestionView: View {
    @EnvironmentObject var bodyInfoStore: BodyInfoStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var canGoNext = false
    
    private var isNextEnabled: Bool {
        bodyInfoStore.weeklyExerciseFrequency != nil &&
        bodyInfoStore.hasPainInfo &&
        bodyInfoStore.fatigue != nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    ProgressView(value: 50, total: 90)
                        .tint(.black)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("최근 컨디션은 어떤가요?")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("부상 예방과 회복 속도 조절에 꼭 필요합니다")
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
                .padding(.bottom, 30)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("주로 어느 부위에 통증이 발생하나요?")
                        .font(.callout)
                        .fontWeight(.medium)
                    
                    let columns = [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ]
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(PainArea.allCases) { area in
                            AppButton(
                                title: area.rawValue,
                                isEnabled: true) {
                                    bodyInfoStore.painArea = area
                                }
                                .font(.callout)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .opacity(bodyInfoStore.painArea == area ? 1.0 : 0.7)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("기타 부위")
                            .font(.subheadline)
                        
                        AppTextField(
                            text: $bodyInfoStore.otherPainArea,
                            placeholder: "부상 부위를 작성하세요"
                        )
                    }
                }
                .padding(.bottom, 30)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("회복 후 피로가 남는 경우가 있나요?")
                        .font(.callout)
                        .fontWeight(.medium)
                    
                    VStack(spacing: 10) {
                        ForEach(Fatigue.allCases) { fatigue in
                            AppButton(
                                title: fatigue.rawValue,
                                isEnabled: true,
                                isLeading: true
                            ) {
                                bodyInfoStore.fatigue = fatigue
                                }
                                .font(.callout)
                                .fontWeight(.medium)
                                .opacity(bodyInfoStore.fatigue == fatigue ? 1.0 : 0.7)
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
    SeventhQuestionView()
        .environmentObject(BodyInfoStore())
}
