import Foundation

struct WorkoutPlanResult: Equatable {
    let rawMarkdown: String
    let parsed: WorkoutPlan
}
