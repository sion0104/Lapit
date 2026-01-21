import Foundation

final class CalendarScoreCache {
    static let shared = CalendarScoreCache()
    private init() {}
    
    struct MonthCache: Codable {
        let fetchedAt: Date
        let scoreByDate: [String: Int]   // "yyyy-MM-dd" -> score
        let codeByDate: [String: String] // 필요하면 사용
    }
    
    private var memory: [String: MonthCache] = [:] // monthKey -> cache
    private let ttl: TimeInterval = 60 * 60 * 6     // 6 hours
    
    // MARK: - Public
    func load(monthKey: String) -> MonthCache? {
        if let m = memory[monthKey], !isExpired(m) { return m }
        if let disk = loadFromDisk(monthKey: monthKey) {
            memory[monthKey] = disk
            if !isExpired(disk) { return disk }
            // 만료여도 "즉시 표시용"으로는 쓸 수 있으니 반환은 하고,
            // 상위에서 백그라운드 refresh 하도록 설계하는 게 UX 좋습니다.
            return disk
        }
        return nil
    }
    
    func save(monthKey: String, cache: MonthCache) {
        memory[monthKey] = cache
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
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
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
