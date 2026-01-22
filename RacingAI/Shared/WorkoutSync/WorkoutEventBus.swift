import Foundation
import Combine

enum WorkoutEvent {
    case workoutSaved(checkDate: String)
}

@MainActor
final class WorkoutEventBus: ObservableObject {
    static let shared = WorkoutEventBus()
    let subject = PassthroughSubject<WorkoutEvent, Never>()
    private init() { }
}
