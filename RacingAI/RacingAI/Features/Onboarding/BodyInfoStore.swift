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
    @Published var seasonGoal: SeasonGoal? = nil
    @Published var affiliation: Affiliation? = nil
    @Published var painArea: PainArea? = nil
    @Published var otherPainArea: String = ""
    @Published var fatigue: Fatigue? = nil
    
    var hasPainInfo: Bool {
        painArea != nil || !otherPainArea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
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

enum SeasonGoal: String, CaseIterable, Identifiable {
    case ImprovedAgility = "순발력 향상 / 스프린트 스타터 중심"
    case StrengtheningDurabiliy = "지속력 강화 / 중장거리 대응력 향상"
    case FasterFatigueRecovery = "피로 회복 속도 향상"
    case StaregyRace = "레이스 전략 적용"
    case ReturnTraining = "복귀 훈련 / 부상 이후 조정기"
    
    var id: Self { self }
}

enum Affiliation: String, CaseIterable, Identifiable {
    case nationalTeamStandingSquad = "선수단 상비군"
    case trainer = "훈련생"
    case personalTraining = "개인 훈련 중"
    
    var id: Self { self }
}

enum PainArea: String, CaseIterable, Identifiable {
    case Hamstring = "햄스트링"
    case Quadriceps = "대퇴사두근"
    case waist = "허리"
    case knee = "무릎"
    case ankle = "발목"
    case shoulderArm = "어깨, 팔"
    
    var id: Self { self }
}

enum Fatigue: String, CaseIterable, Identifiable {
    case low = "거의 없음"
    case medium = "가끔 있음"
    case high = "자주 있음"
    
    var id: Self { self }
}
