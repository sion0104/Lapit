import Foundation

struct ServerErrorBody: Decodable {
    let status: String?
    let message: String?
}

extension Error {
    var userMessage: String {
        if let apiError = self as? APIError {
            return apiError.userMessage
        }
        
        return "요청 처리 중 문제가 발생했어요. 잠시 후 다시 시도해 주세요."
    }
}

extension APIError {
    var userMessage: String {
        switch self {
        case .invalidURL:
            return "요청 주소가 올바르지 않아요."

        case .network:
            return "네트워크 연결을 확인한 뒤 다시 시도해 주세요."

        case .decoding:
            return "데이터 처리 중 문제가 발생했어요. 잠시 후 다시 시도해 주세요."

        case .unknown:
            return "알 수 없는 오류가 발생했어요. 잠시 후 다시 시도해 주세요."

        case .serverStatusCode(let statusCode, let data):
            // 1) 서버 바디에서 message 파싱 시도
            let serverMessage = data.flatMap { decodeServerMessage(from: $0) }

            // 2) 상태코드별 + 메시지별 사용자 문구 정리
            switch statusCode {
            case 401:
                if let msg = serverMessage, !msg.isEmpty {
                    if msg.contains("아이디") && msg.contains("비밀번호") {
                        return "아이디 또는 비밀번호가 올바르지 않아요."
                    }
                    return msg
                }
                return "아이디 또는 비밀번호가 올바르지 않아요."

            case 404:
                return serverMessage ?? "존재하지 않는 계정이에요."

            default:
                return serverMessage ?? "요청 처리 중 문제가 발생했어요. (\(statusCode))"
            }
        }
    }

    private func decodeServerMessage(from data: Data) -> String? {
        if let decoded = try? JSONDecoder().decode(ServerErrorBody.self, from: data) {
            return decoded.message
        }
        return nil
    }
}
