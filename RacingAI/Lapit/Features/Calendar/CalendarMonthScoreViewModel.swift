import Foundation

@MainActor
final class CalendarMonthScoreViewModel: ObservableObject {
    @Published private(set) var scoreByDate: [Date: Int] = [:]
    @Published private(set) var codeByDate: [Date: String] = [:]
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    private let repo: CalendarScoreRepository
    private let calendar = Calendar.current
    private var currentTask: Task<Void, Never>?

    init(repo: CalendarScoreRepository = CalendarScoreRepository()) {
        self.repo = repo
    }

    func load(month: Date, forceRefresh: Bool = false) {
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            guard let self else { return }
            await self.loadInternal(month: month, forceRefresh: forceRefresh)
        }
    }

    func applyInjected(scoreByDate: [Date: Int], codeByDate: [Date: String]) {
        var mergedScore = self.scoreByDate
        for (d, v) in scoreByDate {
            mergedScore[calendar.startOfDay(for: d)] = v
        }

        var mergedCode = self.codeByDate
        for (d, v) in codeByDate {
            mergedCode[calendar.startOfDay(for: d)] = v
        }

        self.scoreByDate = mergedScore
        self.codeByDate = mergedCode
    }

    private func loadInternal(month: Date, forceRefresh: Bool) async {
        errorMessage = nil

        let monthKey = monthKeyString(month)
        let apiMonth = apiMonthString(month)

        // 1) 캐시 즉시 반영
        if let cached = CalendarScoreCache.shared.load(monthKey: monthKey) {
            apply(cache: cached)
        }

        // 2) stale이면 네트워크 갱신 (forceRefresh면 무조건)
        let needsRefresh = forceRefresh ? true : repo.shouldRefresh(monthKey: monthKey)
        guard needsRefresh else {
            prefetchAdjacentMonths(of: month)
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let refreshed = try await repo.getMonth(
                monthKey: monthKey,
                apiMonth: apiMonth,
                forceRefresh: true
            )
            apply(cache: refreshed)
            prefetchAdjacentMonths(of: month)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func apply(cache: CalendarScoreCache.MonthCache) {
        var mergedScore = self.scoreByDate
        var mergedCode  = self.codeByDate

        for (k, v) in cache.scoreByDate {
            if let d = parseDay(k) {
                let key = calendar.startOfDay(for: d)
                // injected(대시보드 기준)이 이미 있으면 그대로 유지
                if mergedScore[key] == nil {
                    mergedScore[key] = v
                }
            }
        }

        for (k, v) in cache.codeByDate {
            if let d = parseDay(k) {
                let key = calendar.startOfDay(for: d)
                mergedCode[key] = v
            }
        }

        self.scoreByDate = mergedScore
        self.codeByDate = mergedCode
    }


    private func prefetchAdjacentMonths(of month: Date) {
        let next = calendar.date(byAdding: .month, value: 1, to: month) ?? month
        let prev = calendar.date(byAdding: .month, value: -1, to: month) ?? month

        let nextKey = monthKeyString(next)
        let nextApiMonth = apiMonthString(next)

        let prevKey = monthKeyString(prev)
        let prevApiMonth = apiMonthString(prev)

        Task.detached { [repo] in
            if repo.shouldRefresh(monthKey: nextKey),
               CalendarScoreCache.shared.load(monthKey: nextKey) == nil {
                _ = try? await repo.getMonth(monthKey: nextKey, apiMonth: nextApiMonth, forceRefresh: true)
            }
        }

        Task.detached { [repo] in
            if repo.shouldRefresh(monthKey: prevKey),
               CalendarScoreCache.shared.load(monthKey: prevKey) == nil {
                _ = try? await repo.getMonth(monthKey: prevKey, apiMonth: prevApiMonth, forceRefresh: true)
            }
        }
    }

    private func monthKeyString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy-MM"
        return f.string(from: date)
    }

    private func parseDay(_ str: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: str)
    }

    private func apiMonthString(_ date: Date) -> String {
        String(calendar.component(.month, from: date)) // "1"..."12"
    }
}
