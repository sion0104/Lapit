import Foundation

@MainActor
final class AICoachPlanViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded(WorkoutPlanResult)
        case failed(String)
    }
    
    @Published private(set) var state: State = .idle
    
    func load(userId: Int, date: Date) async {
        if case .loaded = state { return }
        if case .loading = state { return }
        
        state = .loading
        do {
            let result = try await fetchPlan(userId: userId, date: date)
            state = .loaded(result)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
    
    func forceFail(_ message: String) {
        state = .failed(message)
    }
}

// MARK: - Network + Parsing
private extension AICoachPlanViewModel {
    
    struct TrainingPlanRequest: Encodable {
        let user_id: Int
        let date: String
    }
    
    struct TrainingPlanResponse: Decodable {
        let plan: String
    }
    
    func fetchPlan(userId: Int, date: Date) async throws -> WorkoutPlanResult {
        let url = URL(string: "https://fastapi-fit-675973952276.europe-west1.run.app/training/plan")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let dateString = date.toYMD()
        let body = TrainingPlanRequest(user_id: userId, date: dateString)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200..<300).contains(http.statusCode) else {
            let raw = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "ServerError", code: http.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "HTTP \(http.statusCode)\n\(raw)"
            ])
        }

        let decoded = try JSONDecoder().decode(TrainingPlanResponse.self, from: data)

        let rawMarkdown = normalizeMarkdown(decoded.plan)

        let title = "\(date.monthKorean()) \(date.day())일 운동 계획"
        let parsed = try parsePlanString(rawMarkdown, dateTitle: title)

        return WorkoutPlanResult(rawMarkdown: rawMarkdown, parsed: parsed)
    }

    func normalizeMarkdown(_ raw: String) -> String {
        var text = raw
        text = text.replacingOccurrences(of: "\\n", with: "\n")
        text = text.replacingOccurrences(of: "\r\n", with: "\n")
        text = text.replacingOccurrences(of: "\r", with: "\n")
        return text
    }
    
    func parsePlanString(_ raw: String, dateTitle: String) throws -> WorkoutPlan {
            // 1) 개행/이스케이프 정규화
            var text = raw
            text = text.replacingOccurrences(of: "\\n", with: "\n")
            text = text.replacingOccurrences(of: "\r\n", with: "\n")
            text = text.replacingOccurrences(of: "\r", with: "\n")

            // 2) "## " 헤더 기준 섹션 분할
            let sections = splitMarkdownSections(text)

            let summarySection = sections["요약"] ?? ""
            let trainingSection = sections["훈련 내용"] ?? ""
            let metricsSection = sections["목표 지표"] ?? ""
            let detailSection  = sections["세부 계획"] ?? ""

            // 3) 요약: bullet 제거해서 문장만
            let summaryDescription = summarySection
                .removingMarkdownBullets()
                .trimmingCharacters(in: .whitespacesAndNewlines)

            // 4) 훈련 내용: bullet 유지(보기 좋게)
            let trainingContent = trainingSection
                .trimEmptyLines()

            // 5) 목표 지표 파싱 (마크다운 bullet 형태 대응)
            let avgHR = extractMarkdownValue(in: metricsSection, key: "평균 HR") ?? ""
            let maxSpeed = extractMarkdownValue(in: metricsSection, key: "최고속 구간") ?? ""
            let tes = extractMarkdownValue(in: metricsSection, key: "Training Efficiency Score 목표") ?? ""

            // 6) 세부 계획 파싱
            let warmup = extractMarkdownValue(in: detailSection, key: "워밍업") ?? ""

            // 메인 파트: "- 메인:" 아래의 블록을 배열로
            let mainItems = extractMainItemsFromDetail(detailSection)

            if let cooldown = extractMarkdownValue(in: detailSection, key: "쿨다운"), !cooldown.isEmpty {
            }

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
    
    
    func extractSection(in text: String, header: String) -> String {
        let headers = ["요약", "훈련 내용", "목표 지표", "세부 계획"]
        
        guard let startRange = text.range(of: header) else { return "" }
        let start = startRange.upperBound
        
        var end = text.endIndex
        for h in headers where h != header {
            if let r = text.range(of: h, range: start..<text.endIndex) {
                if r.lowerBound < end { end = r.lowerBound }
            }
        }
        
        let section = String(text[start..<end])
        return section.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func extractValueLine(in section: String, key: String) -> String? {
        let lines = section.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespaces) }
        for line in lines {
            if line.hasPrefix(key) {
                if let colon = line.firstIndex(of: ":") {
                    return line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
                } else {
                    return line.replacingOccurrences(of: key, with: "").trimmingCharacters(in: .whitespaces)
                }
            }
        }
        return nil
    }
    
    func extractMainItems(in detail: String) -> [String] {
        guard let range = detail.range(of: "메인") else { return [] }
        let after = detail[range.upperBound...]
        
        var mainText = String(after)
        mainText = mainText.replacingOccurrences(of: ":", with: "")
        mainText = mainText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let lines = mainText
            .split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var result: [String] = []
        for line in lines {
            if line.hasPrefix("-") || line.hasPrefix("•") {
                if result.isEmpty {
                    result.append(line)
                } else {
                    result[result.count - 1] += "\n" + line
                }
            } else {
                result.append(line)
            }
        }
        return result
    }
}

private extension Date {
    func toYMD() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: self)
    }
    
    func monthKorean() -> String {
        let c = Calendar.current
        return "\(c.component(.month, from: self))월"
    }
    
    func day() -> Int {
        Calendar.current.component(.day, from: self)
    }
}

private extension AICoachPlanViewModel {

    /// "## 요약" 같은 마크다운 헤더 기준으로 섹션 분할
    func splitMarkdownSections(_ text: String) -> [String: String] {
        // 헤더 라인: "## "로 시작
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
                // 이전 섹션 저장
                flush()

                // 새 섹션 시작
                currentHeader = trimmed.replacingOccurrences(of: "## ", with: "")
                    .trimmingCharacters(in: .whitespaces)
            } else {
                // 섹션 내용 누적
                if currentHeader != nil {
                    buffer.append(line)
                }
            }
        }

        flush()
        return result
    }

    /// "- 평균 HR: 130~140 ..." 같은 markdown bullet에서 value 추출
    func extractMarkdownValue(in section: String, key: String) -> String? {
        let lines = section.components(separatedBy: "\n")
        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespaces)

            // "- 키: 값" / "키: 값" 둘 다 허용
            let normalized = line
                .replacingOccurrences(of: "- ", with: "")
                .replacingOccurrences(of: "• ", with: "")
                .trimmingCharacters(in: .whitespaces)

            // "워밍업: ..." 처럼 정확히 key로 시작하는지 확인
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

    /// "## 세부 계획" 안에서 "- 메인:" 아래 항목들을 배열로 뽑기
    /// - 1. / 2. / "- 1분 스프린트 ..." 같은 들여쓰기 포함도 유지
    func extractMainItemsFromDetail(_ detail: String) -> [String] {
        // detail을 라인으로 분해
        let lines = detail.components(separatedBy: "\n")

        // "- 메인:" 라인을 찾고, 그 아래를 모으되,
        // 다음 최상위 bullet("- 쿨다운:" 같은) 나오면 종료
        var isInMain = false
        var collected: [String] = []

        for rawLine in lines {
            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)

            // 메인 시작
            if trimmed.hasPrefix("- 메인") || trimmed.hasPrefix("메인") {
                isInMain = true
                continue
            }

            if isInMain {
                // 메인 종료 조건: "- 쿨다운:" 혹은 "- 워밍업:" 같은 "최상위 bullet"이 나오면 종료
                // (현재 포맷에서는 쿨다운만 보통 있음)
                if trimmed.hasPrefix("- 쿨다운") {
                    // 쿨다운은 mainItems에 포함시키고 싶으면 아래처럼 추가
                    if let cooldown = extractMarkdownValue(in: detail, key: "쿨다운"), !cooldown.isEmpty {
                        collected.append("쿨다운: \(cooldown)")
                    }
                    break
                }

                // 내용 수집 (빈 줄은 스킵)
                if trimmed.isEmpty { continue }

                // 들여쓰기 구조를 유지하고 싶으면 rawLine 그대로 사용
                collected.append(rawLine)
            }
        }

        // 이제 collected를 "아이템 단위"로 뭉치기:
        // - "  1. ..." / "  2. ..." 를 새 아이템 시작으로 보고
        // - 그 아래 들여쓴 "- ..."는 같은 아이템에 붙임
        var result: [String] = []
        var current: [String] = []

        func flush() {
            let joined = current.joined(separator: "\n").trimEmptyLines()
            if !joined.isEmpty { result.append(joined) }
            current.removeAll(keepingCapacity: true)
        }

        for line in collected {
            let t = line.trimmingCharacters(in: .whitespaces)

            // 새 아이템 시작 조건: "1." "2." 또는 "- 1." 같은 경우도 대비
            let startsNumbered = t.range(of: #"^\d+\."#, options: .regularExpression) != nil
            let startsDashNumbered = t.range(of: #"^-+\s*\d+\."#, options: .regularExpression) != nil

            if startsNumbered || startsDashNumbered {
                flush()
                current.append(t.removingLeadingDashSpace())
            } else {
                // 보조 항목은 현재 아이템에 붙이기
                if current.isEmpty {
                    // 혹시 번호 없이 시작하는 라인이면 그대로 하나로
                    current.append(t)
                } else {
                    current.append(t)
                }
            }
        }

        flush()

        // 만약 메인 섹션 자체가 비어있으면 쿨다운만이라도 넣고 싶을 수 있으니 안전 처리
        return result
    }
}

private extension String {
    func trimEmptyLines() -> String {
        let lines = self.components(separatedBy: "\n")
        let trimmedLines = lines
            .map { $0.trimmingCharacters(in: .whitespaces) }

        // 앞/뒤 빈 줄 제거
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



