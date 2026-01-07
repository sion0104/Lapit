import Foundation

enum APIError: Error {
    case invalidURL
    case network(Error)
    case serverStatusCode(Int, Data?)
    case decoding(Error)
    case unknown
}

import Foundation

func describeAPIError(_ error: Error) -> String {
    if let apiError = error as? APIError {
        switch apiError {
        case .invalidURL:
            return "[APIError] invalidURL"

        case .network(let underlying):
            return "[APIError] network error: \(underlying.localizedDescription)"

        case .serverStatusCode(let statusCode, let data):
            var message = "[APIError] serverStatusCode: \(statusCode)"
            if let data,
               let bodyString = String(data: data, encoding: .utf8),
               !bodyString.isEmpty {
                message += "\n[APIError] body: \(bodyString)"
            }
            return message

        case .decoding(let underlying):
            return "[APIError] decoding error: \(underlying.localizedDescription)"

        case .unknown:
            return "[APIError] unknown"
        }
    } else {
        return "[Error] \(error.localizedDescription)"
    }
}

