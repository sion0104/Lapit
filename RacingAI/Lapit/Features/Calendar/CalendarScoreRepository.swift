import Foundation

final class CalendarScoreRepository {
    private let api: APIClient
    private let cache: CalendarScoreCache

    init(api: APIClient = .shared, cache: CalendarScoreCache = .shared) {
        self.api = api
        self.cache = cache
    }

    func getMonth(
        monthKey: String,
        apiMonth: String,
        forceRefresh: Bool = false
    ) async throws -> CalendarScoreCache.MonthCache {

        if !forceRefresh, let cached = cache.load(monthKey: monthKey) {
            return cached
        }

        // 1) 월 API로 "운동한 날짜 목록" 확보
        let monthlyRes = try await api.fetchWorkoutMonthly(month: apiMonth)
        let items = monthlyRes.data

        // 2) 일일 API로 각 날짜의 payload를 병렬로 가져와 "대시보드와 동일한 점수" 계산
        let today = WorkoutDateFormatter.checkDateString(Date())
        let checkDates = items.map(\.checkDate).filter { $0 != today }
        let scoreByDate = await fetchDailyScores(checkDates: checkDates)

        // codeByDate는 지금 월 API에 없으니, 우선은 비워두거나 기본 메시지로 채움
        var codeByDate: [String: String] = [:]
        for it in items {
            codeByDate[it.checkDate] = "해당 날짜의 기록이 있습니다."
        }

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

    // MARK: - Daily Prefetch

    private func fetchDailyScores(checkDates: [String]) async -> [String: Int] {
        let unique = Array(Set(checkDates)).sorted()
        let maxConcurrent = 4

        var results: [String: Int] = [:]
        results.reserveCapacity(unique.count)

        var index = 0
        while index < unique.count {
            let slice = unique[index..<min(index + maxConcurrent, unique.count)]
            index += slice.count

            await withTaskGroup(of: (String, Int?).self) { group in
                for date in slice {
                    group.addTask { [api] in
                        do {
                            let res: CommonResponse<WorkoutDailyPayload> = try await api.fetchWorkoutDaily(checkDate: date)
                            let score = WorkoutScoring.score(from: res.data)   // 대시보드와 동일 점수
                            return (date, score)
                        } catch {
                            // ✅ 특정 날짜 500 나도 month 전체를 실패시키지 않음
                            return (date, nil)
                        }
                    }
                }

                for await (date, score) in group {
                    if let score {
                        results[date] = score
                    }
                }
            }
        }

        return results
    }
}
