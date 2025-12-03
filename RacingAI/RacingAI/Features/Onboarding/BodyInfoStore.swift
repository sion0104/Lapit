import Foundation

final class BodyInfoStore: ObservableObject {
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var bodyFatRate: String = ""
    @Published var weightChange: WeightChange? = nil
    @Published var trainingPartner: TrainingPartner? = nil
    @Published var weeklyExerciseFrequency: ExerciseFrequency? = nil
    @Published var preferredExerciseTime: ExerciseTime? = nil
    @Published var preferredTraning: Training? = nil
}

enum WeightChange: String, CaseIterable, Identifiable {
    case none = "변화 없음"
    case gain = "증량"
    case loss = "감량"
    
    var id: Self { self }
}

enum TrainingPartner: String, CaseIterable, Identifiable {
    case solo = "혼자 훈련해요"
    case withCoachOrTerm = "코치나 팀과 함께해요"
    
    var id: Self { self }
}

enum ExerciseFrequency: String, CaseIterable, Identifiable {
    case zeroToOne = "0~1회"
    case twoToThree = "2~3회"
    case fourToFive = "4~5회"
    case overFive = "5회 이상"
    
    var id: Self { self }
}

enum ExerciseTime: CaseIterable, Identifiable {
    case morning
    case lunch
    case evening
    case irregular
    
    var id: Self { self }
    
    var emoji: String {
        switch self {
        case .morning: return "☀️"
        case .lunch: return "🍽️"
        case .evening: return "🌇"
        case .irregular: return "🔁"
        }
    }
    
    var title: String {
        switch self {
        case .morning: return "아침 시간대"
        case .lunch: return "점심 시간대"
        case .evening: return "저녁 시간대"
        case .irregular: return "일정하지 않음"
        }
    }
    
    var detail: String {
        switch self {
        case .morning: return " 06:00 ~ 09:00"
        case .lunch: return "11:00 ~ 14:00"
        case .evening: return "18:00 ~ 21:00"
        case .irregular: return "요일/시간이 매번 달라요"
        }
    }
}

enum Training: String, CaseIterable, Identifiable {
    case indoor = "실내 파워 트레이닝"
    case track = "트랙 중심 주행 훈련"
    case muscleBalance = "근력 및 밸런스 보강"
    
    var id: Self { self }
}
