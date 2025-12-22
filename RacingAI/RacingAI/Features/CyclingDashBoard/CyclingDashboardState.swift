import Foundation

struct CyclingDashboardState: Equatable {
    // Auth (UI용)
    var hasToken: Bool
    
    // Header
    var userName: String
    var dateText: String            // 예: "11월 3일 오늘"
    var todayText: String
    var weatherText: String         // 예: "맑음 22°C"
    
    // Session (주행)
    var rideDurationText: String    // 예: "01H 20M 45S"
    
    // Metrics
    var distanceText: String        // 예: "12.4 km" or "-- km"
    var distanceGoalHint: String    // 예: "목표까지 3.6km"
    
    var speedText: String           // 예: "22.1 km/h" or "-- km/h"
    var paceHint: String            // 예: "5분간 페이스 유지"
    
    // Health
    var currentBPM: Int             // 예: 150
    var previousBPM: Int            // 예: 143 (2분 전)
    var previousBPMLabel: String    // 예: "2분 전"
    
    var caloriesText: String        // 예: "350 kcal"
    
    // Status cards (백엔드에서 올 예정)
    var conditionTitle: String      // 예: "이번 주 컨디션"
    var conditionLevelText: String  // 예: "주의"
    var conditionDesc: String       // 예: "기분 저조함\n컨디션 좋음"
    
    var exerciseScoreTitle: String  // 예: "운동점수"
    var exerciseScoreValue: Int     // 예: 85
    var exerciseScoreLabel: String  // 예: "높음"
    var exerciseScoreDesc: String   // 예: "잘 하고 있어요!"
    
    // Avg exercise time (HealthKit에서 올 예정)
    var avgExerciseTitle: String    // 예: "평균 운동시간"
    var avgExerciseTimeText: String // 예: "4시간 30분"
    var avgExerciseDesc: String     // 예: "지난주보다 1시간 더\n운동했습니다."
}

extension CyclingDashboardState {
    var bpmDelta: Int { currentBPM - previousBPM }
    var bpmDeltaText: String {
        let d = bpmDelta
        if d == 0 { return "변화 없음" }
        return d > 0 ? "+\(d)" : "\(d)"
    }
}
