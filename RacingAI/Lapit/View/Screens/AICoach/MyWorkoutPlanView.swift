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

    @State private var selectedCheckDate: String
    
    init(checkDate: String) {
        self.checkDate = checkDate
        _selectedCheckDate = State(initialValue: checkDate)
    }


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

               

                HStack {
                    ForEach(segmentDates.indices, id: \.self) { idx in
                        let date = segmentDates[idx]
                        let isSelected = (selectedCheckDate == MyWorkoutPlanView.yyyyMMddStatic(date))

                        Button {
                            selectedCheckDate = MyWorkoutPlanView.yyyyMMddStatic(date)
                            load(for: selectedCheckDate)
                        } label: {
                            Text(label(for: date))
                                .font(isSelected ? .callout : .subheadline)
                                .fontWeight(isSelected ? .medium : .regular)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 37)
                                .background(
                                    RoundedRectangle(cornerRadius: 100)
                                        .foregroundStyle(isSelected ? Color("MainColor") : Color.clear)
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

                            planCheckRow(text: "평균 HR: \(entity.avgHRText)")
                            planCheckRow(text: "최고속 구간: \(entity.maxSpeedText)")
                            planCheckRow(text: "TES 목표: \(entity.tesGoalText)")
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
                            
                            Text("워밍업")
                                .font(.caption)

                            planCheckRow(text: entity.warmupText)

                            Text("메인")
                                .font(.caption)

                            ForEach(entity.mainItems, id: \.self) { item in
                                planCheckRow(text: item)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }

                } else {
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
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
        .task {
            await MainActor.run { load(for: selectedCheckDate) }
        }
    }
    
    private func load(for dateString: String) {
        do {
            print("🔎 load(for:) dateString =", dateString)
            try DailyPlanLocalStore.debugPrintAll(context: modelContext)

            let e = try DailyPlanLocalStore.fetch(by: dateString, context: modelContext)
            self.entity = e
            self.memo = e?.memo ?? ""
            self.errorMessage = (e == nil) ? "저장된 계획을 찾지 못했어요." : nil

            guard let e else {
                self.checklist = []
                return
            }

            let planTexts =
                ["워밍업: \(e.warmupText)"]
                + e.mainItems.map { "메인: \($0)" }
                + ["평균 HR: \(e.avgHRText)",
                   "최고속 구간: \(e.maxSpeedText)",
                   "TES 목표: \(e.tesGoalText)"]

            let saved = Dictionary(uniqueKeysWithValues: e.checklist.map { ($0.text, $0.isDone) })

            self.checklist = planTexts.map { text in
                PlanCheckItem(text: text, isDone: saved[text] ?? false)
            }
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
    
    private func planCheckRow(text: String) -> some View {
        let isDone = checklistIsDone(for: text)

        return Button {
            toggleChecklist(text: text)
            saveLocalOnly()
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.25))
                    .font(.system(size: 18, weight: .semibold))

                Text(text)
                    .font(.body)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
    }

    private func checklistIsDone(for text: String) -> Bool {
        checklist.first(where: { $0.text == text })?.isDone ?? false
    }

    private func toggleChecklist(text: String) {
        if let idx = checklist.firstIndex(where: { $0.text == text }) {
            checklist[idx].isDone.toggle()
        } else {
            // 세부 계획에서 새로 등장한 항목이면 자동 생성
            checklist.append(.init(text: text, isDone: true))
        }
    }
    
    private var segmentDates: [Date] {
        let cal = Calendar.current
        let base = parseYYYYMMDD(selectedCheckDate) ?? cal.startOfDay(for: Date())
        let baseDay = cal.startOfDay(for: base)

        return [
            cal.date(byAdding: .day, value: -1, to: baseDay)!,
            baseDay,
            cal.date(byAdding: .day, value: 1, to: baseDay)!
        ]
    }
    
    private func parseYYYYMMDD(_ s: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: s)
    }

    private func label(for date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = .current
        f.dateFormat = "M월 d일"
        return f.string(from: date)
    }

    private static func yyyyMMddStatic(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
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
