import Foundation

enum WorkoutPlanParser {
    static func parse(raw: String, dateTitle: String) throws -> WorkoutPlan {
        // 1) 개행/이스케이프 정규화
        var text = raw
        text = text.replacingOccurrences(of: "\\n", with: "\n")
        text = text.replacingOccurrences(of: "\r\n", with: "\n")
        text = text.replacingOccurrences(of: "\r", with: "\n")

        // 2) 섹션 분할
        let sections = splitMarkdownSections(text)

        let summarySection  = sections["요약"] ?? ""
        let trainingSection = sections["훈련 내용"] ?? ""
        let metricsSection  = sections["목표 지표"] ?? ""
        let detailSection   = sections["세부 계획"] ?? ""

        let summaryDescription = summarySection
            .removingMarkdownBullets()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let trainingContent = trainingSection.trimEmptyLines()

        let avgHR    = extractMarkdownValue(in: metricsSection, key: "평균 HR") ?? ""
        let maxSpeed = extractMarkdownValue(in: metricsSection, key: "최고속 구간") ?? ""
        let tes      = extractMarkdownValue(in: metricsSection, key: "Training Efficiency Score 목표") ?? ""

        let warmup = extractMarkdownValue(in: detailSection, key: "워밍업") ?? ""
        let mainItems = extractMainItemsFromDetail(detailSection)

        return WorkoutPlan(
            dateTitle: dateTitle,
            summaryTitle: "요약",
            summaryDescription: summaryDescription,
            trainingContent: trainingContent,
            avgHRText: avgHR,
            maxSpeedText: maxSpeed,
            tesGoalText: tes,
            warmupText: warmup,
            mainItems: mainItems
        )
    }

    // MARK: - Helpers (기존 로직 그대로 이동)

    private static func splitMarkdownSections(_ text: String) -> [String: String] {
        let lines = text.components(separatedBy: "\n")

        var result: [String: String] = [:]
        var currentHeader: String? = nil
        var buffer: [String] = []

        func flush() {
            guard let h = currentHeader else { return }
            result[h] = buffer.joined(separator: "\n").trimEmptyLines()
            buffer.removeAll(keepingCapacity: true)
        }

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("## ") {
                flush()
                currentHeader = trimmed.replacingOccurrences(of: "## ", with: "")
                    .trimmingCharacters(in: .whitespaces)
            } else {
                if currentHeader != nil { buffer.append(line) }
            }
        }

        flush()
        return result
    }

    private static func extractMarkdownValue(in section: String, key: String) -> String? {
        let lines = section.components(separatedBy: "\n")
        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            let normalized = line
                .replacingOccurrences(of: "- ", with: "")
                .replacingOccurrences(of: "• ", with: "")
                .trimmingCharacters(in: .whitespaces)

            guard normalized.hasPrefix(key) else { continue }

            if let colon = normalized.firstIndex(of: ":") {
                return normalized[normalized.index(after: colon)...]
                    .trimmingCharacters(in: .whitespaces)
            } else {
                return normalized.replacingOccurrences(of: key, with: "")
                    .trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }

    private static func extractMainItemsFromDetail(_ detail: String) -> [String] {
        let lines = detail.components(separatedBy: "\n")
        var isInMain = false
        var collected: [String] = []

        for rawLine in lines {
            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("- 메인") || trimmed.hasPrefix("메인") {
                isInMain = true
                continue
            }

            if isInMain {
                if trimmed.hasPrefix("- 쿨다운") {
                    if let cooldown = extractMarkdownValue(in: detail, key: "쿨다운"), !cooldown.isEmpty {
                        collected.append("쿨다운: \(cooldown)")
                    }
                    break
                }

                if trimmed.isEmpty { continue }
                collected.append(rawLine)
            }
        }

        var result: [String] = []
        var current: [String] = []

        func flush() {
            let joined = current.joined(separator: "\n").trimEmptyLines()
            if !joined.isEmpty { result.append(joined) }
            current.removeAll(keepingCapacity: true)
        }

        for line in collected {
            let t = line.trimmingCharacters(in: .whitespaces)
            let startsNumbered = t.range(of: #"^\d+\."#, options: .regularExpression) != nil
            let startsDashNumbered = t.range(of: #"^-+\s*\d+\."#, options: .regularExpression) != nil

            if startsNumbered || startsDashNumbered {
                flush()
                current.append(t.removingLeadingDashSpace())
            } else {
                if current.isEmpty { current.append(t) }
                else { current.append(t) }
            }
        }

        flush()
        return result
    }
}

private extension String {
    func trimEmptyLines() -> String {
        let lines = self.components(separatedBy: "\n")
        let trimmedLines = lines.map { $0.trimmingCharacters(in: .whitespaces) }

        var start = 0
        var end = trimmedLines.count

        while start < end, trimmedLines[start].isEmpty { start += 1 }
        while end > start, trimmedLines[end - 1].isEmpty { end -= 1 }

        return trimmedLines[start..<end].joined(separator: "\n")
    }

    func removingMarkdownBullets() -> String {
        self
            .components(separatedBy: "\n")
            .map { line in
                let t = line.trimmingCharacters(in: .whitespaces)
                if t.hasPrefix("- ") { return String(t.dropFirst(2)) }
                if t.hasPrefix("• ") { return String(t.dropFirst(2)) }
                return t
            }
            .joined(separator: "\n")
            .trimEmptyLines()
    }

    func removingLeadingDashSpace() -> String {
        var t = self.trimmingCharacters(in: .whitespaces)
        if t.hasPrefix("- ") { t = String(t.dropFirst(2)) }
        return t
    }
}
