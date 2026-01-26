import Foundation

@MainActor
final class WorkoutDailyStore: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    @Published private(set) var cache: [String: WorkoutDailyPayload] = [:]
    
    @Published private(set) var lastUpdatedVersion: Int = 0
    @Published private(set) var lastUpdatedKey: String = ""
    
    @Published private(set) var loadingKeys: Set<String> = []
    @Published private(set) var errorByKey: [String: String] = [:]

    private var tasks: [String: Task<Void, Never>] = [:]
    
    func preloadTodayIfNeeded() {
        let today = WorkoutDateFormatter.checkDateString(Date())
        preload(checkDate: today)
    }

    func load(checkDate: String) {
        // 이미 이 키 로딩 중이면 중복 실행 방지
        if loadingKeys.contains(checkDate) { return }
        if cache[checkDate] != nil { return }

        tasks[checkDate]?.cancel()
        tasks[checkDate] = Task { [weak self] in
            guard let self else { return }
            await self._load(checkDate: checkDate, force: false)
        }
    }
    
    func cancel(checkDate: String) {
        tasks[checkDate]?.cancel()
        tasks[checkDate] = nil
        loadingKeys.remove(checkDate)
    }

    private func _load(checkDate: String, force: Bool) async {
        loadingKeys.insert(checkDate)
        errorByKey[checkDate] = nil
        defer {
            loadingKeys.remove(checkDate)
            tasks[checkDate] = nil
        }

        // 기존 전체 표시용 변수도 유지하고 싶으면 세팅
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        if Task.isCancelled { return }

        do {
            // force == false인데도 cache가 생겼으면 생략하고 싶다면 여기서 한 번 더 guard 가능
            let res: CommonResponse<WorkoutDailyPayload> = try await APIClient.shared.fetchWorkoutDaily(checkDate: checkDate)

            if Task.isCancelled { return }

            cache[checkDate] = res.data
            lastUpdatedKey = checkDate
            lastUpdatedVersion += 1

        } catch {
            if Task.isCancelled { return }
            let msg = error.localizedDescription
            errorByKey[checkDate] = msg
            errorMessage = msg
        }
    }

    
    func preload(checkDate: String) {
        if cache[checkDate] != nil { return }
        load(checkDate: checkDate)
    }

    func forceReload(checkDate: String) {
        tasks[checkDate]?.cancel()
        tasks[checkDate] = Task { [weak self] in
            guard let self else { return }
            await self._load(checkDate: checkDate, force: true)
        }
    }

    private func _loadForce(checkDate: String) async {
        if Task.isCancelled { return }

        loadingKeys.insert(checkDate)
        errorByKey[checkDate] = nil

        do {
            let res: CommonResponse<WorkoutDailyPayload> =
                try await APIClient.shared.fetchWorkoutDaily(checkDate: checkDate)

            if Task.isCancelled { return }

            cache[checkDate] = res.data
            lastUpdatedKey = checkDate
            lastUpdatedVersion += 1
        } catch {
            if Task.isCancelled { return }
            errorByKey[checkDate] = error.localizedDescription
        }
        loadingKeys.remove(checkDate)
    }
}
