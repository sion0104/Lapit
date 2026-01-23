import Foundation

extension APIClient {
    func fetchWorkoutMonthly(month: String) async throws -> WorkoutMonthlyResponseDTO {
        let items = [URLQueryItem(name: "month", value: month)]
        
        guard let base = URL(string: "/v1/workout/monthly", relativeTo: APIConfig.baseURL) else {
            throw APIError.invalidURL
        }
        var components = URLComponents(url: base, resolvingAgainstBaseURL: true)
        components?.queryItems = items
        
        guard let url = components?.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        attachAuthorizationIfNeeded(to: &request)
        
        print("➡️ [APIClient] Request: GET \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.unknown }
        
        print("⬅️ [APIClient] Response statusCode: \(http.statusCode)")
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.serverStatusCode(http.statusCode, data)
        }
        
        return try JSONDecoder().decode(WorkoutMonthlyResponseDTO.self, from: data)
    }
}
