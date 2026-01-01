import Foundation

final class BodyInfoStore: ObservableObject {
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var bmi: String = ""
    @Published var weightChange: WeightChange? = nil
    @Published var trainingPartner: TrainingPartner? = nil
    @Published var weeklyExerciseFrequency: ExerciseFrequency? = nil
    @Published var preferredExerciseTime: ExerciseTime? = nil
    @Published var ridingExperience: RidingExperience? = nil
    @Published var todayCondition: TodayCondition? = nil
    
    
    func updateBMI() {
        let heihtText = height.trimmingCharacters(in: .whitespacesAndNewlines)
        let weightText = weight.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let h = Double(heihtText.replacingOccurrences(of: ",", with: "."))
        let w = Double(weightText.replacingOccurrences(of: ",", with: "."))
        
        guard let heightCm = h, let weightKg = w, heightCm > 0, weightKg > 0 else {
            return
        }
        
        let heightM = heightCm / 100.0
        let value = weightKg / (heightM * heightM)
        
        bmi = String(format: "%.1f", value)
    }
    
    func trainingPartnerPayload() -> AnswerPayload? {
        guard let partner = trainingPartner else { return nil }

        return AnswerPayload(
            questionId: OnboardingQuestion.trainingPartner.rawValue,
            answerId: partner.id
        )
    }
    
}

enum WeightChange: Int, CaseIterable, Identifiable {
    case none = 11
    case gain = 12
    case loss = 13
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .none: return "변화 없음"
        case .gain: return "중량"
        case .loss: return "감량"
        }
    }
}

enum TrainingPartner: Int, CaseIterable, Identifiable {
    case solo = 21
    case withCoachOrTerm = 22
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .solo: return "혼자 훈련해요"
        case .withCoachOrTerm: return "코치나 팀과 함께해요"
        }
    }
}

enum ExerciseFrequency: Int, CaseIterable, Identifiable {
    case zeroToOne = 31
    case twoToThree = 32
    case fourToFive = 33
    case overFive = 34
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .zeroToOne: return "0~1회"
        case .twoToThree: return "2~3회"
        case .fourToFive: return "4~5회"
        case .overFive: return "5회 이상"
        }
    }
}

enum ExerciseTime: Int, CaseIterable, Identifiable {
    case morning = 41
    case lunch = 42
    case evening = 43
    case irregular = 44
    
    var id: Int { rawValue }
    
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

enum RidingExperience: Int, CaseIterable, Identifiable {
    case beginner = 51
    case intermediate = 52
    case expert = 53
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .beginner: return "사이클을 막 시작했어요"
        case .intermediate: return "어느정도 탈 줄 알아요"
        case .expert: return "사이클을 오래 했어요"
        }
    }
}

enum TodayCondition: Int, CaseIterable, Identifiable {
    case good = 61
    case regular = 62
    case notGood = 63
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .good: return "좋아요"
        case .regular: return "보통이에요"
        case .notGood: return "별로에요"
        }
    }
}

