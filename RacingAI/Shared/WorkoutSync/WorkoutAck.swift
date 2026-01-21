import Foundation

enum WorkoutAckStatus: String, Codable {
    case received
    case started
    case paused
    case resumed
    case stopped
    case failed
}

struct WorkoutAck: Codable {
    let command: WorkoutCommand
    let commandId: String
    let status: WorkoutAckStatus
    let timestamp: Date
    let message: String?
}
