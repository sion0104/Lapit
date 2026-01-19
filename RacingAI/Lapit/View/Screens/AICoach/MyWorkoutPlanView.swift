import SwiftUI
import SwiftData

struct MyWorkoutPlanView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let checkDate: String

    @State private var entity: DailyPlanEntity?
    @State private var checklist: [PlanCheckItem] = []
    @State private var memo: String = ""
    @State private var errorMessage: String?

    // (기존 탭 UI 유지용) - 실제 날짜 리스트는 나중에 확장 가능
    private let dates = ["11월 2일", "11월 3일", "11월 4일"]
    @State private var selectedIndex: Int = 1

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text(checkDate.toKoreanMonthDay())
                    .font(.title3)
                    .fontWeight(.medium)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                // (기존 날짜 세그먼트 UI 유지)
                HStack {
                    ForEach(dates.indices, id: \.self) { idx in
                        Button { selectedIndex = idx } label: {
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

                if let entity {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entity.summaryTitle)
                            .fontWeight(.medium)

                        Divider().padding(.horizontal, 2)

                        Text(entity.summaryDescription)
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

                            Divider().padding(.horizontal, 2)

                            metricRow(title: "평균 HR", value: entity.avgHRText)
                            metricRow(title: "최고속 구간", value: entity.maxSpeedText)
                            metricRow(title: "Training Efficiency Score 목표", value: entity.tesGoalText)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))

                        VStack(alignment: .leading, spacing: 10) {
                            Text("세부 계획")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Divider().padding(.horizontal, 2)

                            metricRow(title: "워밍업", value: entity.warmupText)

                            Text("메인")
                                .font(.caption)

                            ForEach(entity.mainItems.indices, id: \.self) { i in
                                Text(entity.mainItems[i])
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))

                        // ✅ 체크리스트(원하신 “String + Bool 리스트”)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("세부 계획 체크")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Divider().padding(.horizontal, 2)

                            ForEach(checklist.indices, id: \.self) { idx in
                                Button {
                                    checklist[idx].isDone.toggle()
                                    saveLocalOnly()
                                } label: {
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: checklist[idx].isDone ? "checkmark.circle.fill" : "circle")
                                        Text(checklist[idx].text)
                                            .font(.body)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))

                        VStack(alignment: .leading, spacing: 8) {
                            Text("메모")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            TextField("메모를 입력하세요", text: $memo, axis: .vertical)
                                .textFieldStyle(.roundedBorder)

                            Button("메모 저장") {
                                saveLocalOnly()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }

                } else {
                    Text("저장된 계획을 불러오는 중이에요...")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .background(Color("Background"))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 5) {
                    Button { dismiss() } label: {
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
        }
        .navigationBarBackButtonHidden(true)
        .task { load() }
    }

    private func load() {
        do {
            let e = try DailyPlanLocalStore.fetch(by: checkDate, context: modelContext)
            self.entity = e
            self.checklist = e?.checklist ?? []
            self.memo = e?.memo ?? ""
            self.errorMessage = (e == nil) ? "저장된 계획을 찾지 못했어요." : nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    private func saveLocalOnly() {
        guard let entity else { return }
        do {
            entity.checklist = checklist
            entity.memo = memo
            entity.updatedAt = Date()
            try modelContext.save()
        } catch {
            self.errorMessage = error.localizedDescription
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

private extension String {
    func toKoreanMonthDay() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: self) else { return self }
        let c = Calendar.current
        return "\(c.component(.month, from: date))월 \(c.component(.day, from: date))일"
    }
}
