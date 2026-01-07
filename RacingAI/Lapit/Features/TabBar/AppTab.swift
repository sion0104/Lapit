import SwiftUI

enum AppTab: CaseIterable, Hashable {
    case exercise
    case planner
    case aiCoach
    case settings
    
    var title: String {
        switch self {
        case .exercise:
            return "운동"
        case .planner:
            return "플래너"
        case .aiCoach:
            return "AI코치"
        case .settings:
            return "설정"
        }
    }
    
    var systemImage: String {
        switch self {
        case .exercise : return "bicycle"
        case .planner : return "pencil"
        case .aiCoach : return "star"
        case .settings : return "gearshape"
        }
    }
}
