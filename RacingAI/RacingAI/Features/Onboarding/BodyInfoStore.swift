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

enum RidingExperience: String, CaseIterable, Identifiable {
    case beginner = "사이클을 막 시작했어요"
    case intermediate = "어느정도 탈 줄 알아요"
    case expert = "사이클을 오래 했어요"
    
    var id: Self { self }
}

enum TodayCondition: String, CaseIterable, Identifiable {
    case good = "좋아요"
    case regular = "보통이에요"
    case notGood = "별로에요"
    
    var id: Self { self }
}

