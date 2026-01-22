import Foundation

final class CalendarScoreCache {
    static let shared = CalendarScoreCache()
    private init() {}

    struct MonthCache: Codable {
        let fetchedAt: Date
        let scoreByDate: [String: Int]   // "yyyy-MM-dd" -> score
        let codeByDate: [String: String]
    }

    private var memory: [String: MonthCache] = [:]
    private let ttl: TimeInterval = 60 * 60 * 6     // 6 hours

    private let queue = DispatchQueue(label: "CalendarScoreCache.queue", attributes: .concurrent)

    // MARK: - Public
    func load(monthKey: String) -> MonthCache? {
        // 1) 메모리 캐시 (thread-safe read)
        if let m = queue.sync(execute: { memory[monthKey] }), !isExpired(m) {
            return m
        }

        // 2) 디스크 로드
        guard let disk = loadFromDisk(monthKey: monthKey) else { return nil }

        queue.async(flags: .barrier) { [weak self] in
            self?.memory[monthKey] = disk
        }

        // 만료여도 “즉시 표시용”으로는 반환
        return disk
    }

    func save(monthKey: String, cache: MonthCache) {
        queue.async(flags: .barrier) { [weak self] in
            self?.memory[monthKey] = cache
        }
        saveToDisk(monthKey: monthKey, cache: cache)
    }

    func isStale(monthKey: String) -> Bool {
        guard let c = load(monthKey: monthKey) else { return true }
        return isExpired(c)
    }

    // MARK: - Disk
    private func cacheDir() -> URL {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("CalendarMonthCache", isDirectory: true)

        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(
                at: dir,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        return dir
    }

    private func fileURL(monthKey: String) -> URL {
        cacheDir().appendingPathComponent("\(monthKey).json")
    }

    private func loadFromDisk(monthKey: String) -> MonthCache? {
        let url = fileURL(monthKey: monthKey)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(MonthCache.self, from: data)
    }

    private func saveToDisk(monthKey: String, cache: MonthCache) {
        let url = fileURL(monthKey: monthKey)
        guard let data = try? JSONEncoder().encode(cache) else { return }
        try? data.write(to: url, options: [.atomic])
    }

    private func isExpired(_ cache: MonthCache) -> Bool {
        Date().timeIntervalSince(cache.fetchedAt) > ttl
    }
}
