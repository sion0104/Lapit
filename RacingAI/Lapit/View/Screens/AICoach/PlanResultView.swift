import SwiftUI

struct PlanResultView: View {
    let onBack: () -> Void
    let plan: WorkoutPlan
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
            
                Text(plan.dateTitle)
                    .font(.title3)
                    .fontWeight(.medium)
                
                VStack (alignment: .leading, spacing: 10){
                                        
                    VStack(alignment: .leading, spacing: 6) {
                        Text(plan.summaryTitle)
                            .font(.title3)
                            .fontWeight(.medium)
                        Text(plan.summaryDescription)
                            .font(.subheadline)
                    }
                }
                .padding()
                
                sectionTitle("운동 내용")
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("목표 지표")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    metricRow(title: "평균 HR", value: plan.avgHRText)
                    metricRow(title: "최고속 구간", value: plan.maxSpeedText)
                    metricRow(title: "Training Efficiency Score 목표", value: plan.tesGoalText)
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("세부 계획")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("워밍업")
                                .font(.subheadline)
                            Text(plan.warmupText)
                                .font(.body)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("메인")
                                .font(.subheadline)
                            
                            ForEach(plan.mainItems.indices, id: \.self) { idx in
                                Text(plan.mainItems[idx])
                                    .font(.body)
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 5) {
                    Button {
                        dismiss()
                        onBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color("Chevron"))
                    }
                    
                    Text("AI 운동 코칭")
                        .font(.title3)
                        .foregroundStyle(Color("Chevron"))
                        .fontWeight(.medium)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color("Chevron"))
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            AppButton(
                title: "내일 플래너에 등록",
                isEnabled: true) {
                    
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title2)
            .fontWeight(.medium)
    }
    
    @ViewBuilder
    private func metricRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    PlanResultView(
        onBack: { },
        plan: WorkoutPlan(
            dateTitle: "11월 4일 운동 계획",
            summaryTitle: "스피드 내구 강화 (벨로토름/고강도)",
            summaryDescription: """
최고속 유지 구간을 10% 연장하는 데 초점이 있어요.
후반 스프린트 하락 억제가 핵심입니다.
""", trainingContent: "운동내용",
            avgHRText: "150 ~ 160 BPM (ZR)",
            maxSpeedText: "60km/h 이상 4회",
            tesGoalText: "85점+",
            warmupText: "Z2 10' → Z3 5' / 켄던스 95–100",
            mainItems: [
                "1. 고속 주행 90\" @ 60–63km/h (RPE 8–9)\n→ 회복 3' @ Z2",
                "2. 플라잉 스타트 200m × 4\n(출발 가속 최대, 기어비 평소 +1단 시도)"
            ]
        )
    )
}
