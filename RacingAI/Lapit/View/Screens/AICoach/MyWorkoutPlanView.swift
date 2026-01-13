import SwiftUI

struct MyWorkoutPlanView: View {
    @Environment(\.dismiss) private var dismiss

    let initialPlan: WorkoutPlan

    private let dates = ["11월 2일", "11월 3일", "11월 4일"]
    @State private var selectedIndex: Int = 1

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                HStack(spacing: 10) {
                    ForEach(dates.indices, id: \.self) { idx in
                        Button {
                            selectedIndex = idx
                        } label: {
                            Text(dates[idx])
                                .font(.subheadline)
                                .fontWeight(selectedIndex == idx ? .semibold : .regular)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(selectedIndex == idx ? Color.green.opacity(0.2) : Color.gray.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        .foregroundStyle(.primary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("요약")
                        .font(.headline)

                    Text(initialPlan.summaryTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(initialPlan.summaryDescription)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 12) {
                    Text("운동 내용")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("목표 지표").font(.subheadline).fontWeight(.semibold)

                        metricRow(title: "평균 HR", value: initialPlan.avgHRText)
                        metricRow(title: "최고속 구간", value: initialPlan.maxSpeedText)
                        metricRow(title: "Training Efficiency Score 목표", value: initialPlan.tesGoalText)
                    }

                    Divider().padding(.vertical, 6)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("세부 계획").font(.subheadline).fontWeight(.semibold)

                        Text("워밍업").font(.caption).foregroundStyle(.secondary)
                        Text(initialPlan.warmupText).font(.body)

                        Text("메인").font(.caption).foregroundStyle(.secondary)
                        ForEach(initialPlan.mainItems.indices, id: \.self) { i in
                            Text(initialPlan.mainItems[i])
                                .font(.body)
                                .padding(.vertical, 3)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding()
        }
        .navigationTitle("내 운동 계획")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // 달력 버튼 액션(추후)
                } label: {
                    Image(systemName: "calendar")
                }
            }
        }
    }

    private func metricRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.body).fontWeight(.semibold)
        }
    }
}
