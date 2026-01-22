import Foundation

@MainActor
final class WorkoutDailyStore: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    @Published private(set) var cache: [String: WorkoutDailyPayload] = [:]
    
    @Published private(set) var lastUpdatedVersion: Int = 0
    @Published private(set) var lastUpdatedKey: String = ""

    private var task: Task<Void, Never>?

    func preloadTodayIfNeeded() {
        let today = WorkoutDateFormatter.checkDateString(Date())
        if cache[today] != nil { return }
        load(checkDate: today)
    }

    func load(checkDate: String) {
        if cache[checkDate] != nil, isLoading == false { return }

        task?.cancel()
        task = Task { [weak self] in
            guard let self else { return }
            await self._load(checkDate: checkDate)
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }

    private func _load(checkDate: String) async {
        if Task.isCancelled { return }

        isLoading = true
        errorMessage = nil

        do {
            let res: CommonResponse<WorkoutDailyPayload> =
                try await APIClient.shared.fetchWorkoutDaily(checkDate: checkDate)

            if Task.isCancelled { return }

            cache[checkDate] = res.data
            lastUpdatedKey = checkDate
            lastUpdatedVersion += 1
            
        } catch {
            if Task.isCancelled { return }
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func preload(checkDate: String) {
        if cache[checkDate] != nil { return }
        load(checkDate: checkDate)
    }

    func forceReload(checkDate: String) {
        task?.cancel()
        task = Task { [weak self] in
            guard let self else { return }
            await self._loadForce(checkDate: checkDate)
        }
    }

    private func _loadForce(checkDate: String) async {
        if Task.isCancelled { return }

        isLoading = true
        errorMessage = nil

        do {
            let res: CommonResponse<WorkoutDailyPayload> =
                try await APIClient.shared.fetchWorkoutDaily(checkDate: checkDate)

            if Task.isCancelled { return }

            cache[checkDate] = res.data
            lastUpdatedKey = checkDate
            lastUpdatedVersion += 1
        } catch {
            if Task.isCancelled { return }
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
