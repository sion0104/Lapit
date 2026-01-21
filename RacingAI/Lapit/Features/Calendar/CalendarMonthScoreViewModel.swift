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
    
    func load(month: Date) {
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            guard let self else { return }
            await self.loadInternal(month: month)
        }
    }
    
    private func loadInternal(month: Date) async {
        errorMessage = nil
        
        let monthKey = monthKeyString(month)
        
        // 1) 캐시 즉시 반영 (있으면 바로 화면에 점수 뜸)
        if let cached = CalendarScoreCache.shared.load(monthKey: monthKey) {
            apply(cache: cached)
        }
        
        // 2) stale이면 네트워크 갱신
        let needsRefresh = repo.shouldRefresh(monthKey: monthKey)
        guard needsRefresh else {
            // 인접월 프리패치(캐시가 없거나 stale이면 백그라운드로 받아둠)
            prefetchAdjacentMonths(of: month)
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let refreshed = try await repo.getMonth(monthKey: monthKey, forceRefresh: true)
            apply(cache: refreshed)
            prefetchAdjacentMonths(of: month)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func apply(cache: CalendarScoreCache.MonthCache) {
        // String("yyyy-MM-dd") -> Date -> [Date:Int] 변환
        var newScore: [Date: Int] = [:]
        var newCode: [Date: String] = [:]
        
        for (k, v) in cache.scoreByDate {
            if let d = parseDay(k) {
                newScore[calendar.startOfDay(for: d)] = v
            }
        }
        for (k, v) in cache.codeByDate {
            if let d = parseDay(k) {
                newCode[calendar.startOfDay(for: d)] = v
            }
        }
        
        self.scoreByDate = newScore
        self.codeByDate = newCode
    }
    
    private func prefetchAdjacentMonths(of month: Date) {
        let next = calendar.date(byAdding: .month, value: 1, to: month) ?? month
        let prev = calendar.date(byAdding: .month, value: -1, to: month) ?? month
        
        Task.detached { [repo] in
            let nextKey = await self.monthKeyString(next)
            if repo.shouldRefresh(monthKey: nextKey), CalendarScoreCache.shared.load(monthKey: nextKey) == nil {
                _ = try? await repo.getMonth(monthKey: nextKey, forceRefresh: true)
            }
        }
        
        Task.detached { [repo] in
            let prevKey = await self.monthKeyString(prev)
            if repo.shouldRefresh(monthKey: prevKey), CalendarScoreCache.shared.load(monthKey: prevKey) == nil {
                _ = try? await repo.getMonth(monthKey: prevKey, forceRefresh: true)
            }
        }
    }
    
    private func monthKeyString(_ date: Date) -> String {
        // "yyyy-MM"
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM"
        return f.string(from: date)
    }
    
    private func parseDay(_ str: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: str)
    }
}
