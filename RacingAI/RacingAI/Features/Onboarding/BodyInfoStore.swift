import Foundation

final class BodyInfoStore: ObservableObject {
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var bodyFatRate: String = ""
    @Published var weightChange: WeightChange? = nil
    @Published var trainingPartner: TrainingPartner? = nil
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
