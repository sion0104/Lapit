import SwiftUI

struct WorkoutDashboardLikeView: View {
    @EnvironmentObject private var store: WorkoutDailyStore
    
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    
    @State private var selectedDayIndex: Int = 0
    @State private var dayNumbers: [Int] = []
        
    @State private var score: Int = 85
    
    @State private var feedbackMemo: String = "오늘 작성된 내용이 없습니다"
    
    @State private var exerciseResultTitle: String = "-"
    @State private var exerciseResultDetail: String = "-"

    @State private var caloriesValue: String = "-"
    @State private var caloriesDetail: String = "-"

    @State private var hrAverage: Int = 0
    @State private var hrMin: Int = 0
    @State private var hrMax: Int = 0
    @State private var hrBars: [Double] = []
    @State private var hrXAxisLabels: [String] = ["", "", "", ""]
    @State private var hrMaxLabel: String = ""

    @State private var avgSpeed: String = "-"
    @State private var avgSpeedDetail: String = "-"

    @State private var distance: String = "-"
    @State private var distanceDetail: String = "-"

    @State private var conditionTitle: String = "-"
    @State private var conditionDetail: String = "-"
    
    @State private var scrollToDay: Int? = nil
        
    private var selectedDay: Int? {
        dayNumbers.indices.contains(selectedDayIndex) ? dayNumbers[selectedDayIndex] : nil
    }

    private var selectedDate: Date? {
        guard let day = selectedDay else { return nil }

        let cal = Calendar(identifier: .gregorian)
        let now = Date()

        var comps = DateComponents()
        comps.calendar = cal
        comps.timeZone = TimeZone(identifier: "Asia/Seoul")
        comps.year = cal.component(.year, from: now)
        comps.month = cal.component(.month, from: now)
        comps.day = day
        comps.hour = 0
        comps.minute = 0
        comps.second = 0

        return cal.date(from: comps)
    }
    
    private var selectedCheckDateString: String? {
        guard let selectedDate else { return nil }
        return WorkoutDateFormatter.checkDateString(selectedDate)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                topDateRow
                
                WorkoutScoreGaugeView(
                    score: score,
                    title: "운동 점수",
                    message: "훈련을 잘 하고 있어요!",
                    ringScale: 1.18
                )
                .frame(height: 175)
                .padding(.top, 30)

                // MARK: Feedback Memo
                card {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("피드백 메모")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button {
                                // TODO: memo edit
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Divider()
                            .padding(.horizontal, 2)
                        
                        Text(feedbackMemo)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // MARK: Diagnosis Section
                sectionHeader("운동 진단")
                
                VStack(spacing: 12) {
                    infoCard(
                        title: "운동 결과",
                        value: exerciseResultTitle,
                        valueStyle: .accent,
                        detail: exerciseResultDetail
                    )
                    
                    infoCard(
                        title: "소모 칼로리",
                        value: caloriesValue,
                        valueStyle: .accent,
                        detail: caloriesDetail
                    )
                }
                
                // MARK: Today Workout Data
                sectionHeader("운동 데이터")
                
                // Heart Rate Card
                card {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("심박수")
                            .fontWeight(.medium)
                        
                        Divider()
                            .padding(.horizontal, 2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("평균 심박수 \(hrAverage) BPM")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("최고 \(hrMax), 최저 \(hrMin)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if hrBars.isEmpty {
                            Text("심박 데이터가 없습니다")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            HeartRatePillChart(
                                values: hrBars,
                                maxLabel: hrMaxLabel.isEmpty ? " " : hrMaxLabel,
                                xLabels: hrXAxisLabels
                            )
                        }
                    }
                }
                
                // Avg Speed
                card {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("평균 주행속도")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(avgSpeed)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        
                        Text(avgSpeedDetail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Distance
                card {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("주행거리")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(distance)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        
                        Text(distanceDetail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Condition
                card {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("컨디션")
                            .fontWeight(.medium)
                        
                        Text(conditionTitle)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(conditionDetail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("2025년 11월 3일 월요일")
                    .font(.title3)
                    .foregroundStyle(.black)
                    .fontWeight(.bold)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color("Chevron"))
                }
            }
        }
        .onAppear {
            refreshMonthDays()
            scrollToDay = Calendar.current.component(.day, from: Date())

            if let checkDate = selectedCheckDateString {
                if let cached = store.cache[checkDate] {
                    apply(payload: cached)
                } else {
                    store.load(checkDate: checkDate)
                }
            }
        }
        .onChange(of: selectedDayIndex, {
            guard let checkDate = selectedCheckDateString else { return }

               if let cached = store.cache[checkDate] {
                   apply(payload: cached)
               } else {
                   store.load(checkDate: checkDate)
               }
        })
        .onChange(of: store.lastUpdatedKey) { _, key in
            guard let key,
                  key == selectedCheckDateString,
                  let payload = store.cache[key] else { return }
            apply(payload: payload)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    
    private func refreshMonthDays(baseDate: Date = Date()) {
        let cal = Calendar.current
        let range = cal.range(of: .day, in: .month, for: baseDate) ?? 1..<2
        dayNumbers = Array(range)

        let today = cal.component(.day, from: baseDate)
        selectedDayIndex = dayNumbers.firstIndex(of: today) ?? 0

        scrollToDay = today
    }
    
    @MainActor
    private func apply(payload: WorkoutDailyPayload) {
        
        print("📊 [WorkoutDailyPayload]")
        print("  • checkDate:", payload.checkDate)
        print("  • avgHeartRate:", payload.avgHeartRate)
        print("  • minHeartRate:", payload.minHeartRate)
        print("  • maxHeartRate:", payload.maxHeartRate)
        print("  • avgPower:", payload.avgPower)
        print("  • totalCalories:", payload.totalCaloriesKcal)
        print("  • avgSpeed:", payload.avgSpeed)
        print("  • totalDistance:", payload.totalDistance)
        print("  • avgRideSec:", payload.avgRideSec)
        print("  • workoutMeasureList count:", payload.workoutMeasureList.count)

        if let condition = payload.dailyCondition {
            print("  • condition:",
                  "mood:", condition.moodScore,
                  "fatigue:", condition.fatigueScore,
                  "recovery:", condition.recoveryState)
        } else {
            print("  • condition: nil")
        }

        if let plan = payload.dailyPlan {
            print("  • plan memo:", plan.memo)
        } else {
            print("  • plan: nil")
        }
        
        hrAverage = Int(payload.avgHeartRate.rounded())
        hrMin = Int(payload.minHeartRate.rounded())
        hrMax = Int(payload.maxHeartRate.rounded())
        
        let points: [(date: Date, hr: Int)] = payload.workoutMeasureList.compactMap { m -> (date: Date, hr: Int)? in
            guard let d = WorkoutDateFormatter.backendStringDate(m.measureAt) else { return nil }
            return (d, m.heartRate) as? (date: Date, hr: Int)
        }
        .sorted { $0.date < $1.date }

        hrXAxisLabels = makeTimeLabels(from: points.map(\.date), count: 4)

        let hrs = points.map(\.hr).filter { $0 > 0 }
        let norm = normalizeWithPercentileClamp(values: hrs, lowerP: 0.05, upperP: 0.95)

        hrBars = norm.values
        hrMaxLabel = norm.displayMaxLabel

        caloriesValue = "\(Int(payload.totalCaloriesKcal.rounded() ))kcal"
        caloriesDetail = "어려운만큼 칼로리를 더 소모했습니다"

        avgSpeed = String(format: "%.2f km/h", payload.avgSpeed)
        avgSpeedDetail = String(format: "(최저 %.0fkm/h ~ 최고 %.0fkm/h)", payload.minSpeed, payload.maxSpeed)

        distance = String(format: "%.0f km", payload.totalDistance)
        distanceDetail = "이번주 목표까지 10km 남았습니다"

        if payload.avgPower >= 250 {
            exerciseResultTitle = "Excellent"
        } else if payload.avgPower >= 180 {
            exerciseResultTitle = "Perfect"
        } else {
            exerciseResultTitle = "Good"
        }

        let rideSec = payload.avgRideSec ?? 0

        exerciseResultDetail =
        "평균 BPM \(Int(payload.avgHeartRate.rounded())), 파워 데이터 \(Int(payload.avgPower.rounded()))W\n오늘 운동시간 \(formatRideTime(rideSec))"

        if let plan = payload.dailyPlan, !plan.memo.isEmpty {
            feedbackMemo = plan.memo
        } else {
            feedbackMemo = "오늘 작성된 내용이 없습니다"
        }

        if let c = payload.dailyCondition {
            conditionTitle = c.recoveryState
            conditionDetail = "기분 \(c.moodScore), 피로 \(c.fatigueScore)\n통증 부위: \(c.painArea)"
        } else {
            conditionTitle = "기록 없음"
            conditionDetail = ""
        }
    }

    private func formatRideTime(_ sec: Int) -> String {
        let h = sec / 3600
        let m = (sec % 3600) / 60
        let s = sec % 60
        if h > 0 { return "\(h)H \(m)M \(s)S" }
        return "\(m)M \(s)S"
    }

    private func makeHeartRateBars(from list: [WorkoutMeasure], minHR: Double, maxHR: Double) -> [Double] {
        let hr = list.map(\.heartRate).filter { $0 > 0 }
        guard !hr.isEmpty else { return [] }

        let lo = minHR > 0 ? minHR : (hr.min() ?? 0)
        let hi = maxHR > 0 ? maxHR : (hr.max() ?? (lo + 1))

        let denom = max(hi - lo, 1e-6)
        return hr.map { ($0 - lo) / denom } // 0...1
    }

    private func makeTimeLabels(from dates: [Date], count: Int) -> [String] {
        guard let minD = dates.min(), let maxD = dates.max(), count >= 2 else {
            return Array(repeating: "", count: max(count, 1))
        }

        let total = maxD.timeIntervalSince(minD)
        let step = total / Double(count - 1)

        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "ko_KR")
        df.timeZone = TimeZone(identifier: "Asia/Seoul")
        df.dateFormat = "HH:mm"

        return (0..<count).map { i in
            let t = minD.addingTimeInterval(step * Double(i))
            return df.string(from: t)
        }
    }

    private struct NormalizedResult {
        let values: [Double]
        let displayMaxLabel: String
    }

    private func normalizeWithPercentileClamp(values: [Int], lowerP: Double, upperP: Double) -> NormalizedResult {
        guard !values.isEmpty else { return .init(values: [], displayMaxLabel: "") }

        let sorted = values.sorted()
        let lo = percentile(sorted, p: lowerP)
        let hi = percentile(sorted, p: upperP)
        let denom = max(hi - lo, 1)

        let clamped = values.map { min(max($0, lo), hi) }
        let normalized = clamped.map { Double($0 - lo) / Double(denom) }

        return .init(values: normalized, displayMaxLabel: "\(hi)")
    }

    private func percentile(_ sorted: [Int], p: Double) -> Int {
        let n = sorted.count
        if n == 1 { return sorted[0] }

        let clampedP = min(max(p, 0), 1)
        let idx = clampedP * Double(n - 1)
        let lo = Int(floor(idx))
        let hi = Int(ceil(idx))

        if lo == hi { return sorted[lo] }
        let w = idx - Double(lo)
        let v = Double(sorted[lo]) * (1 - w) + Double(sorted[hi]) * w
        return Int(round(v))
    }

    
    // MARK: - Top UI Components
    private var topDateRow: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(dayNumbers, id: \.self) { day in
                        let idx = dayNumbers.firstIndex(of: day) ?? 0
                        let isSelected = selectedDayIndex == idx

                        Button {
                            selectedDayIndex = idx
                            scrollToDay = day
                        } label: {
                            Text("\(day)")
                                .font(.footnote)
                                .frame(width: 48, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 100)
                                        .fill(isSelected ? Color.mint : Color.clear)
                                )
                        }
                        .foregroundStyle(.primary)
                        .id(day)
                    }
                }
                .padding(.horizontal, 2)
            }
            .onChange(of: scrollToDay) { _, day in
                guard let day else { return }
                DispatchQueue.main.async {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(day, anchor: .center)
                    }
                }
            }
        }
    }

    func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
            
            Spacer()
        }
        .padding(.top, 24)
    }
}



// MARK: - Reusable Cards

private extension WorkoutDashboardLikeView {
    func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))

    }
    
    enum ValueStyle {
        case accent
        case normal
    }
    
    func infoCard(title: String, value: String, valueStyle: ValueStyle, detail: String) -> some View {
        card {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Text(title)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button {
                        // TODO: info
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(.question)
                    }
                }
                
                Divider()
                    .padding(.horizontal, 2)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(valueStyle == .accent ? Color.mint : .primary)
                
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Mini Bar Chart (Heart Rate)

struct MiniBarChart: View {
    var values: [Double]  // 0...1
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let count = max(values.count, 1)
            let spacing: CGFloat = 4
            let barWidth = max(3, (w - CGFloat(count - 1) * spacing) / CGFloat(count))
            
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(values.indices, id: \.self) { i in
                    let v = min(max(values[i], 0), 1)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.red.opacity(0.8))
                        .frame(width: barWidth, height: max(2, h * v))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }
}



// MARK: - Preview

#Preview {
    NavigationStack {
        WorkoutDashboardLikeView()
    }
}
