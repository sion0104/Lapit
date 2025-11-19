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
