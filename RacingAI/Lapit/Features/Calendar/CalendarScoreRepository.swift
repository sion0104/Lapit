import Foundation

final class CalendarScoreRepository {
    private let api: APIClient
    private let cache: CalendarScoreCache
    
    init(api: APIClient = .shared, cache: CalendarScoreCache = .shared) {
        self.api = api
        self.cache = cache
    }
    
    /// 1) 캐시 있으면 즉시 반환 (만료여도 우선 표시 가능)
    /// 2) stale이면 네트워크로 갱신 후 저장
    func getMonth(monthKey: String, forceRefresh: Bool = false) async throws -> CalendarScoreCache.MonthCache {
        if !forceRefresh, let cached = cache.load(monthKey: monthKey) {
            // stale 여부는 상위(vm)에서 판단해도 되고, 여기서 바로 refresh 해도 됨
            return cached
        }
        
        let res = try await api.fetchWorkoutMonthly(month: monthKey)
        let (scoreByDate, codeByDate) = mapScores(items: res.data)
        
        let newCache = CalendarScoreCache.MonthCache(
            fetchedAt: Date(),
            scoreByDate: scoreByDate,
            codeByDate: codeByDate
        )
        cache.save(monthKey: monthKey, cache: newCache)
        return newCache
    }
    
    func shouldRefresh(monthKey: String) -> Bool {
        cache.isStale(monthKey: monthKey)
    }
    
    private func mapScores(items: [WorkoutMonthlyItemDTO]) -> ([String: Int], [String: String]) {
        var scoreByDate: [String: Int] = [:]
        let codeByDate: [String: String] = [:]
        
        for item in items {
            let avgPower = item.avgPower ?? 0
            let targetPower = item.totalAvgPower // 없으면 nil
            
            // 속도 정보가 없다면 0/ nil로 두어 speed 패널티는 0 처리
            let score = WorkoutScoreCalculator.calculate(
                avgSpeedKmh: 0,
                avgPowerW: avgPower,
                targetSpeedKmh: nil,
                targetPowerW: targetPower
            )
            
            scoreByDate[item.checkDate] = score
            
            // codeByDate는 서버가 어떤 “코드”를 주는지 모르니 예시로 비워둠.
            // 만약 서버가 workout type 코드 등을 준다면 여기서 매핑하세요.
            // codeByDate[item.checkDate] = item.someCode
        }
        
        return (scoreByDate, codeByDate)
    }
}
