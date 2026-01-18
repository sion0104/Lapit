import SwiftUI

struct MyWorkoutPlanView: View {

    @Environment(\.dismiss) private var dismiss

    let initialPlan: WorkoutPlan

    private let dates = ["11월 2일", "11월 3일", "11월 4일"]
    @State private var selectedIndex: Int = 1

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                HStack {
                    ForEach(dates.indices, id: \.self) { idx in
                        Button {
                            selectedIndex = idx
                        } label: {
                            Text(dates[idx])
                                .font(selectedIndex == idx ? .callout : .subheadline)
                                .fontWeight(selectedIndex == idx ? .medium : .regular)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 37)
                                .background(
                                    RoundedRectangle(cornerRadius: 100)
                                        .foregroundStyle(selectedIndex == idx ? Color("MainColor") : Color.clear)
                                )
                                    
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .padding(.vertical, 3)
                .frame(maxWidth: .infinity)
                .background {
                    Rectangle()
                      .foregroundColor(.clear)
                      .background(.white)
                      .cornerRadius(100)
                      .shadow(color: Color(red: 0.82, green: 0.82, blue: 0.84).opacity(0.2), radius: 2, x: 0, y: 2)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(initialPlan.summaryTitle)
                        .fontWeight(.medium)
                    
                    Divider()
                        .padding(.horizontal, 2) 

                    Text(initialPlan.summaryDescription)
                        .font(.footnote)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))


                    
                VStack(alignment: .leading, spacing: 12) {
                    Text("운동 내용")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("목표 지표")
                            .fontWeight(.medium)
                        
                        Divider()
                            .padding(.horizontal, 2)

                        metricRow(title: "평균 HR", value: initialPlan.avgHRText)
                        metricRow(title: "최고속 구간", value: initialPlan.maxSpeedText)
                        metricRow(title: "Training Efficiency Score 목표", value: initialPlan.tesGoalText)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))


                    VStack(alignment: .leading, spacing: 10) {
                        Text("세부 계획").font(.subheadline).fontWeight(.semibold)
                        
                        Divider()
                            .padding(.horizontal, 2)

                        metricRow(
                            title: "워밍업",
                            value: initialPlan.warmupText)


                        Text("메인")
                            .font(.caption)
                        ForEach(initialPlan.mainItems.indices, id: \.self) { i in
                            Text(initialPlan.mainItems[i])
                                .font(.body)
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
            }
            .padding()
        }
        .background(
            Color("Background")
        )
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 5) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color("Chevron"))
                    }

                    Text("내 운동 계획")
                        .font(.title3)
                        .foregroundStyle(.black)
                        .fontWeight(.medium)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    Button {
                        // TODO: 계획 짜기 버튼
                    } label: {
                        Text("계획 짜기")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .foregroundStyle(.black)
                            .background(
                                LinearGradient(
                                stops: [
                                Gradient.Stop(color: .white, location: 0.00),
                                Gradient.Stop(color: Color("Gradient").opacity(0.7), location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 1),
                                endPoint: UnitPoint(x: 0.5, y: 0)
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 100))
                    }
                    .shadow(color: Color("Grdaient" ).opacity(0.2), radius: 2, x: 0, y: 2)
                    .overlay(
                    RoundedRectangle(cornerRadius: 100)
                    .inset(by: 0.25)
                    .stroke(Color("Gradient"), lineWidth: 0.5)
                    )
                    
                    Button {
                        // TODO: 캘린더 버튼
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundStyle(.black)
                    }
                }
            }
        }
    }

    private func metricRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.black)
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationStack {
        MyWorkoutPlanView(
            initialPlan: WorkoutPlan(
                dateTitle: "11월 3일",
                summaryTitle: "회복 중심 지구력 훈련",
                summaryDescription: "오늘 훈련은 회복을 최우선으로 하며, 저강도 지구력 주행과 짧은 인터벌을 조합합니다.",
                trainingContent: "사이클링",
                avgHRText: "130 ~ 140 BPM",
                maxSpeedText: "45 km/h 이상 2회",
                tesGoalText: "80점 이상",
                warmupText: "Z2 15분 → Z3 5분 (케이던스 90~95)",
                mainItems: [
                    "지구력 주행 20분 @ 25~30 km/h (RPE 5~6)",
                    "회복 5분 @ Z1",
                    "1분 스프린트 @ 40 km/h 이상 → 회복 3분 @ Z2 (3세트)",
                    "쿨다운 Z1 10분"
                ]
            )
        )
    }
}

