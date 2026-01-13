import Foundation

struct WorkoutPlan: Codable, Equatable {
    let dateTitle: String
    let summaryTitle: String
    let summaryDescription: String
    
    let trainingContent: String
    
    let avgHRText: String
    let maxSpeedText: String
    let tesGoalText: String
    
    let warmupText: String
    let mainItems: [String]
}
