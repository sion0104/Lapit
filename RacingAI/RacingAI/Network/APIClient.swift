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

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
