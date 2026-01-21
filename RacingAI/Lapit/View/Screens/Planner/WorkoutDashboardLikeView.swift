import SwiftUI

struct WorkoutDashboardLikeView: View {
    @EnvironmentObject private var store: WorkoutDailyStore
    
    private let calendar = Calendar(identifier: .gregorian)
    
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
            
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
    @State private var hrMinLabel: String = ""


    @State private var avgSpeed: String = "-"
    @State private var avgSpeedDetail: String = "-"

    @State private var distance: String = "-"
    @State private var distanceDetail: String = "-"

    @State private var conditionTitle: String = "-"
    @State private var conditionDetail: String = "-"
    
    @State private var caloriesTrend: CaloriesTrend = .none
    @State private var exerciseResultColor: Color = .primary
    
    @State private var score: Int = 85
    
    @State private var didWorkoutToday: Bool = false
    
    @State private var goCalendar: Bool = false
    @State private var selectedDay: Date = Calendar(identifier: .gregorian).startOfDay(for: Date())

    
    private var todayDate: Date {
        let cal = Calendar(identifier: .gregorian)
        let now = Date()
        return cal.startOfDay(for: now)
    }

    private var todayCheckDateString: String {
        WorkoutDateFormatter.checkDateString(selectedDay)
    }

    private var todayTitleString: String {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "ko_KR")
        df.timeZone = TimeZone(identifier: "Asia/Seoul")
        df.dateFormat = "yyyy년 M월 d일 EEEE"
        return df.string(from: selectedDay)
    }

    private enum CaloriesTrend {
        case up
        case down
        case none
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    WorkoutScoreGaugeView(
                        score: score,
                        didWorkout: didWorkoutToday,
                        title: "운동 점수",
                        ringScale: 1.18
                    )
                    .frame(height: 175)
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
                            value: exerciseResultTitle, valueColor: exerciseResultColor,
                            detail: exerciseResultDetail
                        )
                        
                        caloriesInfoCard(
                            title: "소모 칼로리",
                            value: caloriesValue,
                            detail: caloriesDetail,
                            trend: caloriesTrend
                        )
                    }
                    
                    // MARK: Today Workout Data
                    sectionHeader("운동 데이터")
                    
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
                                    minLabel: hrMinLabel.isEmpty ? " " : hrMinLabel,
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
                        }
                    }
                    
                    Spacer(minLength: 24)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(todayTitleString)
                        .font(.title3)
                        .foregroundStyle(.black)
                        .fontWeight(.bold)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        goCalendar = true
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundStyle(Color("Chevron"))
                    }
                }
            }
            .onAppear {
                selectedDay = Calendar(identifier: .gregorian).startOfDay(for: Date())
                load(for: selectedDay)
            }
            .onChange(of: store.lastUpdatedVersion) { _, _ in
                let key = WorkoutDateFormatter.checkDateString(selectedDay)
                guard let payload = store.cache[key] else { return }
                apply(payload: payload)
            }
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $goCalendar) {
                CalendarView(
                    scoreByDate: makeScoreByDate(),
                    codeByDate: makeCodeByDate(),
                    onSelect: { date in
                        selectedDay = calendar.startOfDay(for: date)
                        goCalendar = false
                        load(for: selectedDay)
                    }
                )
            }
        }
    }
    
    @MainActor
    private func load(for date: Date) {
        let checkDate = WorkoutDateFormatter.checkDateString(date)

        if let cached = store.cache[checkDate] {
            apply(payload: cached)
        } else {
            store.load(checkDate: checkDate)
        }
    }
    
    @MainActor
    private func apply(payload: WorkoutDailyPayload) {

        let hasDetails = !payload.details.isEmpty
        let todayKcal = Int(payload.totalCaloriesKcal.rounded())
        let didWorkout = hasDetails || payload.durationSec > 0 || todayKcal > 0
        didWorkoutToday = didWorkout
        if didWorkout == false {
            score = 0
        }

        // -----------------------------
        // 1) 심박 (details 기반)
        // -----------------------------
        let points: [(date: Date, hr: Int)] = payload.details.compactMap { m -> (date: Date, hr: Int)? in
            guard let d = WorkoutDateFormatter.backendStringDate(m.measureAt) else { return nil }
            let hr = Int(m.heartRate.rounded())
            return (d, hr)
        }
        .sorted { $0.date < $1.date }

        let hrs = points.map(\.hr).filter { $0 > 0 }
        if hrs.isEmpty {
            hrAverage = 0
            hrMin = 0
            hrMax = 0
            hrBars = []
            hrXAxisLabels = ["", "", "", ""]
            hrMaxLabel = ""
            hrMinLabel = ""
        } else {
            // avg/min/max는 details에서 계산
            hrAverage = Int(Double(hrs.reduce(0, +)) / Double(hrs.count))
            hrMin = hrs.min() ?? 0
            hrMax = hrs.max() ?? 0

            hrXAxisLabels = makeTimeLabels(from: points.map(\.date), count: 4)

            let norm = normalizeWithPercentileClamp(values: hrs, lowerP: 0.05, upperP: 0.95)
            hrBars = norm.values
            hrMaxLabel = norm.displayMaxLabel
            hrMinLabel = norm.displayMinLabel
        }

        // -----------------------------
        // 2) 칼로리 (prev 비교)
        // -----------------------------
        caloriesValue = "\(todayKcal)kcal"

        let prevKcal = Int(payload.prevTotalCaloriesKcal.rounded())
        if prevKcal <= 0 {
            caloriesDetail = ""
            caloriesTrend = .none
        } else if todayKcal > prevKcal {
            caloriesDetail = "어제보다 칼로리를 더 소모했습니다"
            caloriesTrend = .up
        } else if todayKcal < prevKcal {
            caloriesDetail = "어제보다 칼로리 소모량이 낮습니다"
            caloriesTrend = .down
        } else {
            caloriesDetail = ""
            caloriesTrend = .none
        }

        // -----------------------------
        // 3) 속도/거리 (단위 변환!)
        // -----------------------------
        let avgSpeedKmh = payload.avgSpeed * 3.6
        let maxSpeedKmh = payload.maxSpeed * 3.6

        avgSpeed = String(format: "%.2f km/h", avgSpeedKmh)
        // minSpeed는 payload에 없으니 details에서 계산(없으면 0)
        let minSpeedKmh = (payload.details.map(\.speed).filter { $0 > 0 }.min() ?? 0) * 3.6
        avgSpeedDetail = String(format: "(최저 %.0fkm/h ~ 최고 %.0fkm/h)", minSpeedKmh, maxSpeedKmh)

        let distanceKm = payload.totalDistance / 1000.0
        distance = String(format: "%.1f km", distanceKm)
        distanceDetail = "이번주 목표까지 10km 남았습니다"
        
        // -----------------------------
        // 3.5) 운동 점수(TS) 계산
        // -----------------------------
        if didWorkout {
            let targetSpeedKmh: Double? = nil
            let targetPowerW: Double? = nil

            score = WorkoutScoreCalculator.calculate(
                avgSpeedKmh: avgSpeedKmh,
                avgPowerW: payload.avgPower,
                targetSpeedKmh: targetSpeedKmh,
                targetPowerW: targetPowerW
            )
        } else {
            score = 0
        }


        // -----------------------------
        // 4) 운동 결과 색/타이틀
        // -----------------------------
        if didWorkout == false {
            exerciseResultTitle = "운동을 하지 않았습니다."
            exerciseResultColor = Color(.good)
        } else if payload.avgPower >= 250 {
            exerciseResultTitle = "Excellent"
            exerciseResultColor = Color(.excellent)
        } else if payload.avgPower >= 180 {
            exerciseResultTitle = "Perfect"
            exerciseResultColor = Color(.perfect)
        } else {
            exerciseResultTitle = "Good"
            exerciseResultColor = Color(.good)
        }

        // -----------------------------
        // 5) 운동 결과 상세(시간은 durationSec 사용)
        // -----------------------------
        exerciseResultDetail =
        "평균 BPM \(hrAverage), 파워 데이터 \(Int(payload.avgPower.rounded()))W\n오늘 운동시간 \(formatRideTime(payload.durationSec))"

        // -----------------------------
        // 6) 메모/컨디션 (기존 유지)
        // -----------------------------
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
        let displayMinLabel: String
    }

    private func normalizeWithPercentileClamp(values: [Int], lowerP: Double, upperP: Double) -> NormalizedResult {
        guard !values.isEmpty else {
            return .init(values: [], displayMaxLabel: "", displayMinLabel: "")
        }

        let sorted = values.sorted()
        let lo = percentile(sorted, p: lowerP)
        let hi = percentile(sorted, p: upperP)
        let denom = max(hi - lo, 1)

        let clamped = values.map { min(max($0, lo), hi) }
        let normalized = clamped.map { Double($0 - lo) / Double(denom) }

        return .init(
            values: normalized,
            displayMaxLabel: "\(hi)",
            displayMinLabel: "\(lo)"
        )
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

    func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
            
            Spacer()
        }
        .padding(.top, 24)
    }
    
    private func makeScoreByDate() -> [Date: Int] {
        var dict: [Date: Int] = [:]
        for (_, payload) in store.cache {
            if let first = payload.details.first,
               let d = WorkoutDateFormatter.backendStringDate(first.measureAt) {
                let day = calendar.startOfDay(for: d)

                let avgSpeedKmh = payload.avgSpeed * 3.6
                let didWorkout = !payload.details.isEmpty || payload.durationSec > 0 || payload.totalCaloriesKcal > 0

                if didWorkout {
                    dict[day] = WorkoutScoreCalculator.calculate(
                        avgSpeedKmh: avgSpeedKmh,
                        avgPowerW: payload.avgPower,
                        targetSpeedKmh: nil,
                        targetPowerW: nil
                    )
                } else {
                    dict[day] = 0
                }
            }
        }
        return dict
    }

    private func makeCodeByDate() -> [Date: String] {
        var dict: [Date: String] = [:]
        for (_, payload) in store.cache {
            if let first = payload.details.first,
               let d = WorkoutDateFormatter.backendStringDate(first.measureAt) {
                let day = calendar.startOfDay(for: d)

                if let plan = payload.dailyPlan, !plan.memo.isEmpty {
                    dict[day] = plan.memo
                } else {
                    dict[day] = "해당 날짜의 기록이 없습니다."
                }
            }
        }
        return dict
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
    
    func infoCard(
        title: String,
        value: String,
        valueColor: Color,
        detail: String
    ) -> some View {
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
                    .foregroundStyle(valueColor)

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func caloriesInfoCard(title: String, value: String, detail: String, trend: CaloriesTrend) -> some View {
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

                HStack(spacing: 6) {
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.mint)

                    if trend != .none {
                        TrendTriangle(trend: trend)
                            .padding(.top, 1)
                    }

                    Spacer()
                }

                if !detail.isEmpty {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
    
    private struct TrendTriangle: View {
        let trend: WorkoutDashboardLikeView.CaloriesTrend

        var body: some View {
            RoundedTriangle()
                .fill(trend == .up ? Color.blue : Color.red)
                .frame(width: 14, height: 12)
                .rotationEffect(trend == .up ? .degrees(0) : .degrees(180))
        }
    }

    private struct RoundedTriangle: Shape {
        var cornerRadius: CGFloat = 2.2

        func path(in rect: CGRect) -> Path {
            // 삼각형 꼭짓점 3개
            let p1 = CGPoint(x: rect.midX, y: rect.minY) // top
            let p2 = CGPoint(x: rect.maxX, y: rect.maxY) // bottom-right
            let p3 = CGPoint(x: rect.minX, y: rect.maxY) // bottom-left

            // 간단한 "둥근" 처리: 각 변 중간으로 들어가면서 곡선 연결
            let m12 = CGPoint(x: (p1.x + p2.x)/2, y: (p1.y + p2.y)/2)
            let m23 = CGPoint(x: (p2.x + p3.x)/2, y: (p2.y + p3.y)/2)
            let m31 = CGPoint(x: (p3.x + p1.x)/2, y: (p3.y + p1.y)/2)

            var path = Path()
            path.move(to: m31)
            path.addQuadCurve(to: m12, control: p1)
            path.addQuadCurve(to: m23, control: p2)
            path.addQuadCurve(to: m31, control: p3)
            path.closeSubpath()
            return path
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
            .environmentObject(WorkoutDailyStore())
    }
}
