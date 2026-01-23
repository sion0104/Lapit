import Foundation

final class APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    private let baseURL: URL
    
    init(
        session: URLSession = .shared,
        baseURL: URL = APIConfig.baseURL
    ) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func get<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        print("➡️ [APIClient] Request: \(request.httpMethod ?? "GET") \(url.absoluteString)")
        
        attachAuthorizationIfNeeded(to: &request)
        

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            print("❌ [APIClient] Network error: \(error.localizedDescription)")
            throw APIError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [APIClient] Not HTTPURLResponse")
            throw APIError.unknown
        }

        print("⬅️ [APIClient] Response statusCode: \(httpResponse.statusCode)")

        guard (200..<300).contains(httpResponse.statusCode) else {
            if let body = String(data: data, encoding: .utf8) {
                print("❌ [APIClient] Server error body: \(body)")
            } else {
                print("❌ [APIClient] Server error body: <non-utf8> \(data.count) bytes")
            }
            throw APIError.serverStatusCode(httpResponse.statusCode, data)
        }

        let decoder = JSONDecoder()

        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            if let jsonString = String(data: data, encoding: .utf8) {
                print("❌ [APIClient] Decoding error: \(error.localizedDescription)")
                print("📦 [APIClient] Raw JSON: \(jsonString)")
            }
            throw APIError.decoding(error)
        }
    }
}

extension APIClient {
    func delete<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        print("➡️ [APIClient] Request: DELETE \(url.absoluteString)")
        
        attachAuthorizationIfNeeded(to: &request)
        
        let (data, response): (Data, URLResponse)
        
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            print("❌ [APIClient] Network error: \(error.localizedDescription)")
            throw APIError.network(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [APIClient] Not HTTPURLResponse")
           throw APIError.unknown
        }
        
        print("⬅️ [APIClient] Response statusCode: \(httpResponse.statusCode)")

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.serverStatusCode(httpResponse.statusCode, data)
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            if let jsonString = String(data: data, encoding: .utf8) {
                print("❌ [APIClient] Decoding error: \(error.localizedDescription)")
                print("📦 [APIClient] Raw JSON: \(jsonString)")
            }
            throw APIError.decoding(error)
        }
    }
}

extension APIClient {
    func postMultipartWithParam<T: Decodable, Param: Encodable>(
        _ path: String,
        param: Param,
        profileImageData: Data?,
        fileFieldName: String = "profileImg"
    ) async throws -> T {
        
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)",
                         forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // param(JSON) 파트
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        
        let jsonData = try encoder.encode(param)
        
        print("📨 [APIClient] PARAM JSON:\n\(String(data: jsonData, encoding: .utf8) ?? "")")
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"param\"\r\n")
        body.append("Content-Type: application/json; charset=utf-8\r\n\r\n")
        body.append(jsonData)
        body.append("\r\n")
        
        // 이미지(선택)
        if let data = profileImageData {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(fileFieldName)\"; filename=\"profile.jpg\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(data)
            body.append("\r\n")
            
            print("🖼 [APIClient] profileImg attached (\(data.count) bytes)")
        } else {
            print("🖼 [APIClient] No profileImg")
        }
        
        // 종료
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        print("➡️ [APIClient] POST multipart to \(url)")
        
        attachAuthorizationIfNeeded(to: &request)
        
        let (data, response) = try await session.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        
        print("⬅️ [APIClient] status: \(http.statusCode)")
        
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.serverStatusCode(http.statusCode, data)
        }
        
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            print("❌ decode error:", error)
            print("📦 raw json:", String(data: data, encoding: .utf8) ?? "")
            throw APIError.decoding(error)
        }
    }
}

extension APIClient {
    func post<T: Decodable, Body: Encodable>(
        _ path: String,
        body: Body
    ) async throws -> T {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept") // ✅ 추가
        request.httpBody = try JSONEncoder().encode(body)

        attachAuthorizationIfNeeded(to: &request)

        print("➡️ [APIClient] Request: POST \(url.absoluteString)")
        logRequestBody(request)

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        print("⬅️ [APIClient] Response statusCode: \(http.statusCode)")
        if let bodyString = String(data: data, encoding: .utf8) {
            print("📦 [APIClient] Response body:\n\(bodyString)")
        } else {
            print("📦 [APIClient] Response body: <non-utf8> \(data.count) bytes")
        }

        guard (200..<300).contains(http.statusCode) else {
            throw APIError.serverStatusCode(http.statusCode, data)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            // ✅ 디코딩 실패 이유를 콘솔에서 바로 확인 가능
            throw APIError.decoding(error)
        }
    }
}

extension APIClient {
    func postWithQuery<T: Decodable>(
        _ path: String,
        queryItems: [URLQueryItem],
        attachAuth: Bool = true   // ✅ 추가
    ) async throws -> T {
        guard let base = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }

        var components = URLComponents(url: base, resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        print("➡️ [APIClient] Request: POST \(url.absoluteString)")

        if attachAuth {
            attachAuthorizationIfNeeded(to: &request)
        } else {
            request.setValue(nil, forHTTPHeaderField: "Authorization")
            print("🔐 [APIClient] Authorization skipped (attachAuth=false)")
        }

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        print("⬅️ [APIClient] Response statusCode: \(http.statusCode)")

        guard (200..<300).contains(http.statusCode) else {
            throw APIError.serverStatusCode(http.statusCode, data)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

extension APIClient {
    func postForm<T: Decodable>(
        _ path: String,
        form: [String: String]
    ) async throws -> T {

        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let bodyString = form
            .map { key, value in
                "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            }
            .joined(separator: "&")

        request.httpBody = bodyString.data(using: .utf8)

        print("➡️ [APIClient] Request: POST \(url.absoluteString)")
        logRequestBody(request)
        print("📨 [APIClient] FormBody: \(bodyString)")
        
        attachAuthorizationIfNeeded(to: &request)

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        print("⬅️ [APIClient] Response statusCode: \(http.statusCode)")

        guard (200..<300).contains(http.statusCode) else {
            throw APIError.serverStatusCode(http.statusCode, data)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

extension APIClient {
    func getVoidWithQuery(
        _ path: String,
        queryItems: [URLQueryItem]
    ) async throws {
        
        guard let base = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        
        var components = URLComponents(url: base, resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        attachAuthorizationIfNeeded(to: &request)
        
        print("➡️ [APIClient] Request: GET \(url.absoluteString)")
        
        let (_, response) = try await session.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        
        print("⬅️ [APIClient] Response statusCode: \(http.statusCode)")

       guard (200..<300).contains(http.statusCode) else {
           throw APIError.serverStatusCode(http.statusCode, nil)
       }
    }
}

extension APIClient {
    func putMultiPartWithParamVoid<Param: Encodable>(
        _ path: String,
        param: Param,
        profileImageData: Data?,
        fileFieldName: String = "profileImg"
    ) async throws {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("multipart/form-data; boundary=\(boundary)",
                         forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // param(JSON) 파트
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        
        let jsonData = try encoder.encode(param)
        
        print("📨 [APIClient] PARAM JSON:\n\(String(data: jsonData, encoding: .utf8) ?? "")")
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"param\"\r\n")
        body.append("Content-Type: application/json; charset=utf-8\r\n\r\n")
        body.append(jsonData)
        body.append("\r\n")
        
        // 이미지(선택)
        if let data = profileImageData {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(fileFieldName)\"; filename=\"profile.jpg\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(data)
            body.append("\r\n")
            
            print("🖼 [APIClient] profileImg attached (\(data.count) bytes)")
        } else {
            print("🖼 [APIClient] No profileImg")
        }
        
        // 종료
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        print("➡️ [APIClient] Put multipart to \(url)")
        
        attachAuthorizationIfNeeded(to: &request)
        
        let (data, response) = try await session.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        
        print("⬅️ [APIClient] status: \(http.statusCode)")
        
        
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.serverStatusCode(http.statusCode, data)
        }
    }
}


// MARK: - Multipart Logging Helper
private extension APIClient {
    func logMultipartFormRequest(
        path: String,
        params: [String: String],
        profileImageData: Data?
    ) {
        print("📡 [APIClient] MultipartForm Request")
        print("➡️ Endpoint: \(path)")
        
        print("📨 Fields:")
        for (key, value) in params {
            if key == "password" {
                print("  - \(key): ********")
            } else {
                print("  - \(key): \(value)")
            }
        }
        
        if let terms = params["termsList"] {
            print("  - termsList(raw): \(terms)")
        }
        
        if let imageData = profileImageData {
            let sizeKB = Double(imageData.count) / 1024.0
            print("🖼️ profileImg: \(String(format: "%.2f", sizeKB)) KB 포함")
        } else {
            print("🖼️ profileImg: 없음")
        }
        
        print("──────────────────────────────────────────────")
    }
}

extension APIClient {
    func getUserInfo() async throws -> User {
        let response: CommonResponse<User> = try await get("/v1/user")
        return response.data
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension APIClient {
    func attachAuthorizationIfNeeded(to request: inout URLRequest) {
        guard let raw = TokenStore.shared.loadAuthorizationValue() else {
            request.setValue(nil, forHTTPHeaderField: "Authorization")
            print("🔐 [APIClient] Authorization removed (no token)")
            return
        }

        let sanitized = AuthorizationSanitizer.sanitize(raw)
        request.setValue(sanitized, forHTTPHeaderField: "Authorization")

        print("🔐 [APIClient] Authorization attached (rawLen: \(raw.count), sanitizedLen: \(sanitized.count))")
//        print("🔐 [APIClient] Authorization prefix:", sanitized.prefix(20))
    }
}


extension APIClient {
    func registerOnboard(_ req: RegisterOnboardReq) async throws -> CommonResponse<UserIdPayload> {
        try await post("/v1/auth/onboard", body: req)
    }
}

extension APIClient {
    func fetchDailyAIPlan(checkDate: String) async throws -> CommonResponse<DailyAIPlanPayload> {
        let items = [URLQueryItem(name: "checkDate", value: checkDate)]

        guard let base = URL(string: "/v1/daily-plan/ai", relativeTo: APIConfig.baseURL) else {
            throw APIError.invalidURL
        }
        var components = URLComponents(url: base, resolvingAgainstBaseURL: true)
        components?.queryItems = items
        guard let url = components?.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")

        attachAuthorizationIfNeeded(to: &request)

        print("➡️ [APIClient] Request: GET \(url.absoluteString)")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.unknown }

        print("⬅️ [APIClient] Response statusCode: \(http.statusCode)")

        guard (200..<300).contains(http.statusCode) else {
            throw APIError.serverStatusCode(http.statusCode, data)
        }

        return try JSONDecoder().decode(CommonResponse<DailyAIPlanPayload>.self, from: data)
    }
}


extension APIClient {
    func postVoid<Body: Encodable>(
        _ path: String,
        body: Body
    ) async throws {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        attachAuthorizationIfNeeded(to: &request)

        print("➡️ [APIClient] Request: POST \(url.absoluteString)")
        logRequestBody(request)

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        print("⬅️ [APIClient] Response statusCode: \(http.statusCode)")
        if let bodyString = String(data: data, encoding: .utf8), !bodyString.isEmpty {
            print("📦 [APIClient] Response body: \(bodyString)")
        } else {
            print("📦 [APIClient] Response body: <empty> (\(data.count) bytes)")
        }

        guard (200..<300).contains(http.statusCode) else {
            throw APIError.serverStatusCode(http.statusCode, data)
        }

    }
}

extension APIClient {
    func fetchWorkoutDaily(checkDate: String) async throws -> CommonResponse<WorkoutDailyPayload> {
        let items = [URLQueryItem(name: "checkDate", value: checkDate)]

        guard let base = URL(string: "/v1/workout/daily", relativeTo: APIConfig.baseURL) else {
            throw APIError.invalidURL
        }
        var components = URLComponents(url: base, resolvingAgainstBaseURL: true)
        components?.queryItems = items

        guard let url = components?.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        attachAuthorizationIfNeeded(to: &request)

        print("➡️ [APIClient] Request: GET \(url.absoluteString)")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.unknown }

        print("⬅️ [APIClient] Response statusCode: \(http.statusCode)")
        
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 [APIClient] Raw JSON:\n\(jsonString)")
        }

        guard (200..<300).contains(http.statusCode) else {
            throw APIError.serverStatusCode(http.statusCode, data)
        }

        return try JSONDecoder().decode(CommonResponse<WorkoutDailyPayload>.self, from: data)
    }
}

private extension APIClient {
    func logRequestBody(_ request: URLRequest) {
        guard let body = request.httpBody else {
            print("📨 [APIClient] Body: <empty>")
            return
        }

        if let contentType = request.value(forHTTPHeaderField: "Content-Type") {
            print("📨 [APIClient] Content-Type: \(contentType)")
        }

        // JSON
        if let json = try? JSONSerialization.jsonObject(with: body),
           let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let jsonString = String(data: pretty, encoding: .utf8) {

            print("📨 [APIClient] Body(JSON):\n\(jsonString)")
            return
        }

        // UTF-8 Text (form-urlencoded 등)
        if let text = String(data: body, encoding: .utf8) {
            print("📨 [APIClient] Body(Text):\n\(text)")
            return
        }

        // Binary
        print("📨 [APIClient] Body(Binary): \(body.count) bytes")
    }
}




