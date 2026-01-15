enum AuthorizationSanitizer {
    static func sanitize(_ raw: String) -> String {
        var v = raw
        if v.lowercased().hasPrefix("authorization:") {
            v = v.dropFirst("authorization:".count).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        v = v.trimmingCharacters(in: .whitespacesAndNewlines)
        v = v.replacingOccurrences(of: "\n", with: "")
        v = v.replacingOccurrences(of: "\r", with: "")
        v = v.replacingOccurrences(of: "\t", with: " ")

        while v.contains("  ") { v = v.replacingOccurrences(of: "  ", with: " ") }

        let lower = v.lowercased()

        if lower.hasPrefix("bearer:") {
            v = "Bearer " + v.dropFirst("bearer:".count).trimmingCharacters(in: .whitespaces)
        }

        if v.lowercased().hasPrefix("bearer bearer ") {
            v = "Bearer " + v.dropFirst("bearer bearer ".count)
        }

        if !v.lowercased().hasPrefix("bearer ") {
            v = "Bearer " + v
        }

        return v
    }
}
