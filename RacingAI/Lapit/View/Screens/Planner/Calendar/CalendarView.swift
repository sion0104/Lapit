import SwiftUI

struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss
    private let calendar = Calendar.current
    
    @StateObject private var vm = CalendarMonthScoreViewModel()

    private let scoreByDate: [Date: Int]
    private let codeByDate: [Date: String]
    private let onSelect: (Date) -> Void

    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date? = nil

    @GestureState private var dragTranslation: CGFloat = 0
    @State private var animatingOffset: CGFloat = 0

    private let monthChangeThreshold: CGFloat = 90
    private let maxRubberBand: CGFloat = 140
    
    private var combinedOffset: CGFloat {
        animatingOffset + rubberBand(dragTranslation)
    }
    
    private var pullUp: CGFloat {
        max(0, -dragTranslation)
    }

    private var previewHeight: CGFloat {
        let h = 160 + (pullUp * 0.6)
        return min(max(h, 160), 360)
    }

    private var previewOpacity: CGFloat {
        let o = 0.25 + min(0.5, pullUp / 300)
        return min(max(o, 0.25), 0.75)
    }
    
    @State private var transitionDelta: Int = 0   // +1: next, -1: prev

    private var pullDown: CGFloat { max(0, dragTranslation) }     // 아래로 당김(이전달)

    // next preview (아래)
    private var nextPreviewHeight: CGFloat {
        let h = 160 + (pullUp * 0.6)
        return min(max(h, 160), 360)
    }
    private var nextPreviewOpacity: CGFloat {
        let o = 0.25 + min(0.5, pullUp / 300)
        return min(max(o, 0.25), 0.75)
    }

    // prev preview (위) — 기본은 안 보이다가 아래로 당길수록 내려오며 보이게
    private var prevPreviewHeight: CGFloat {
        let h = 0 + (pullDown * 0.6)          // 기본 0 → 아래로 당길수록 증가
        return min(max(h, 0), 260)            // 최대치 취향대로
    }
    private var prevPreviewOpacity: CGFloat {
        let o = 0.0 + min(0.65, pullDown / 260)
        return min(max(o, 0.0), 0.65)
    }
    
    private var calendarMaxHeight: CGFloat {
        // 6주(42칸) 기준
        let cellHeight: CGFloat = 72
        let rowCount: CGFloat = 6
        let rowSpacing: CGFloat = 8
        let dividerCount: CGFloat = 5
        let dividerHeight: CGFloat = 1

        let gridHeight =
            (cellHeight * rowCount) +
            (rowSpacing * (rowCount - 1)) +
            (dividerHeight * dividerCount)

        let weekdayHeight: CGFloat = 24
        let topSpacing: CGFloat = 12
        let bottomSpacing: CGFloat = 12

        // 현재달 + 프리뷰가 살짝 보일 여유
        return weekdayHeight + gridHeight + topSpacing + bottomSpacing + 80
    }


    init(
        scoreByDate: [Date: Int],
        codeByDate: [Date: String],
        onSelect: @escaping (Date) -> Void
    ) {
        let cal = Calendar.current
        self.scoreByDate = Dictionary(uniqueKeysWithValues: scoreByDate.map { (cal.startOfDay(for: $0.key), $0.value) })
        self.codeByDate  = Dictionary(uniqueKeysWithValues: codeByDate.map  { (cal.startOfDay(for: $0.key), $0.value) })
        self.onSelect = onSelect
    }

    var body: some View {
        VStack(spacing: 12) {

            // ✅ 월 타이틀(원하시는 좌상단)
            HStack {
                Text(monthTitle(currentMonth))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                Spacer()
                Image(systemName: "calendar")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
            }

            ZStack {
                monthStack(month: currentMonth)
                    .id(currentMonth)
                    .transition(monthTransition)
            }
            .frame(maxHeight: calendarMaxHeight)
            .clipped()
            .offset(y: combinedOffset)
            .animation(.interactiveSpring(), value: animatingOffset)
            .contentShape(Rectangle())
            .simultaneousGesture(monthDragGesture)

        }
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 8)
        .onAppear {
            selectedDate = calendar.startOfDay(for: Date())
            currentMonth = startOfMonth(Date())
            vm.load(month: currentMonth)
        }
        .onChange(of: currentMonth) { _, newValue in
            vm.load(month: newValue)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 5) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.black)
                    }

                    Text("월별 운동 기록")
                        .font(.title3)
                        .foregroundStyle(Color("Chevron"))
                        .fontWeight(.medium)
                }
            }
        }
    }

    // MARK: - Grid
    private func calendarGrid(month: Date, isPreview: Bool) -> some View {
        let days = makeDaysForMonthGrid(month: month)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

        return VStack(spacing: 6) {

            // 요일
            HStack {
                ForEach(weekdaySymbols(), id: \.self) { s in
                    Text(s)
                        .font(.caption)
                        .foregroundStyle(isPreview ? .secondary : .primary)
                        .frame(maxWidth: .infinity)
                }
            }

            Divider().padding(.horizontal, 2)

            // 주 단위 렌더링 + 구분선
            ForEach(0..<days.count / 7, id: \.self) { week in
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        let index = week * 7 + dayIndex
                        let day = days[index]

                        DayCell(
                            day: day,
                            month: month,
                            selectedDate: $selectedDate,
                            score: day.flatMap { vm.scoreByDate[calendar.startOfDay(for:  $0)] },
                            isPreview: isPreview,
                            onTap: { tappedDay in
                                selectedDate = calendar.startOfDay(for: tappedDay)
                                onSelect(tappedDay)
                                dismiss()
                            }
                        )
                    }
                }

                if week != days.count / 7 - 1 {
                    Divider().padding(.horizontal, 2)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers
    private func monthTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월"
        return f.string(from: date)
    }
    
    private func weekdaySymbols() -> [String] {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        return f.shortWeekdaySymbols
    }

    private func makeDaysForMonthGrid(month: Date) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let firstDayOfMonth = monthInterval.start
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)?.count ?? 0

        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        let leadingEmptyCount = (weekday - calendar.firstWeekday + 7) % 7

        var result: [Date?] = Array(repeating: nil, count: leadingEmptyCount)

        for day in 1...daysInMonth {
            var comp = calendar.dateComponents([.year, .month], from: firstDayOfMonth)
            comp.day = day
            result.append(calendar.date(from: comp))
        }

        while result.count < 42 { result.append(nil) }
        if result.count > 42 { result = Array(result.prefix(42)) }

        return result
    }

    
    private var monthDragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .updating($dragTranslation) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                // ✅ 관성 반영: predictedEndTranslation 사용
                let predicted = value.predictedEndTranslation.height
                let actual = value.translation.height

                // 둘 중 더 강한 쪽(절댓값 큰)을 사용하면 스크롤 느낌이 좋아짐
                let t = abs(predicted) > abs(actual) ? predicted : actual

                if t <= -monthChangeThreshold {
                    changeMonth(by: 1)
                } else if t >= monthChangeThreshold {
                    changeMonth(by: -1)
                } else {
                    // 원위치 복귀 애니메이션(부드럽게)
                    withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.9)) {
                        animatingOffset = 0
                    }
                }
            }
    }

    private func changeMonth(by delta: Int) {
        transitionDelta = delta

        let direction: CGFloat = delta > 0 ? -1 : 1

        // 살짝 “밀리는” 연출
        withAnimation(.interactiveSpring(response: 0.22, dampingFraction: 0.85)) {
            animatingOffset = direction * 18
        }

        // 실제 월 변경 (여기서 transition 발생)
        withAnimation(.easeInOut(duration: 0.28)) {
            animatingOffset = 0
            currentMonth = startOfMonth(calendar.date(byAdding: .month, value: delta, to: currentMonth) ?? currentMonth)
        }
    }
    
    private func startOfMonth(_ date: Date) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start ?? date
    }

    private func nextMonth(_ date: Date) -> Date {
        calendar.date(byAdding: .month, value: 1, to: date) ?? date
    }
    
    private func prevMonth(_ date: Date) -> Date {
        calendar.date(byAdding: .month, value: -1, to: date) ?? date
    }
    
    private func rubberBand(_ raw: CGFloat) -> CGFloat {
        // 스크롤 땡김처럼 점점 저항이 생기는 느낌
        let sign: CGFloat = raw >= 0 ? 1 : -1
        let x = min(abs(raw), maxRubberBand)
        let normalized = x / maxRubberBand
        let eased = 1 - (1 - normalized) * (1 - normalized) // quadratic ease-out
        return sign * eased * maxRubberBand
    }
    
    @ViewBuilder
    private func monthStack(month: Date) -> some View {
        VStack(alignment: .leading, spacing: 18) {

            // ✅ (A) prevMonth 프리뷰: 아래로 끌면 위에서 내려오며 보임
            VStack(alignment: .leading, spacing: 10) {
                Text(monthTitle(prevMonth(month)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .opacity(prevPreviewOpacity)

                calendarGrid(month: prevMonth(month), isPreview: true)
                    .frame(height: prevPreviewHeight)   // ✅ 드래그에 비례
                    .clipped()
                    .opacity(prevPreviewOpacity)
                    .allowsHitTesting(false)
            }

            // ✅ (B) 현재 달 (진하게)
            calendarGrid(month: month, isPreview: false)

            // ✅ (C) nextMonth 프리뷰: 위로 끌면 더 드러나게
            VStack(alignment: .leading, spacing: 10) {
                Text(monthTitle(nextMonth(month)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .opacity(nextPreviewOpacity)

                calendarGrid(month: nextMonth(month), isPreview: true)
                    .frame(height: nextPreviewHeight)    // ✅ 드래그에 비례
                    .clipped()
                    .opacity(nextPreviewOpacity)
                    .allowsHitTesting(false)
            }
        }
    }
    
    private var monthTransition: AnyTransition {
        // next(+1): 새달이 아래에서 올라오고, 기존달은 위로 사라짐
        // prev(-1): 새달이 위에서 내려오고, 기존달은 아래로 사라짐
        let insertionEdge: Edge = (transitionDelta >= 0) ? .bottom : .top
        let removalEdge: Edge = (transitionDelta >= 0) ? .top : .bottom

        return .asymmetric(
            insertion: .move(edge: insertionEdge).combined(with: .opacity),
            removal: .move(edge: removalEdge).combined(with: .opacity)
        )
    }

}

private struct DayCell: View {
    let day: Date?
    let month: Date
    @Binding var selectedDate: Date?
    let score: Int?
    let isPreview: Bool
    let onTap: (Date) -> Void

    private let calendar = Calendar.current

    var body: some View {
        let isToday = day.map { calendar.isDateInToday($0) } ?? false

        Button {
            if let day { onTap(day) }
        } label: {
            ZStack {
                // 날짜 숫자: 셀 내부 좌상단
                VStack {
                    HStack {
                        Text(dayNumberString(day))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(isToday && !isPreview ? .mint : (isPreview ? .secondary : .black))
                        Spacer()
                    }
                    Spacer()
                }

                // 점수
                if let score {
                    VStack {
                        Spacer()
                        Text("\(score)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(isPreview ? .mint : .black)
                            .padding(.bottom, 6)
                    }
                }
            }
            .frame(height: 72)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(day == nil)
    }

    private func dayNumberString(_ date: Date?) -> String {
        guard let date else { return "" }
        return String(calendar.component(.day, from: date))
    }
}
