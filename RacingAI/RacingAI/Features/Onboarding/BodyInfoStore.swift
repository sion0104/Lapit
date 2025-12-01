import Foundation

final class BodyInfoStore: ObservableObject {
    @Published var height: String = ""
    @Published var weight: String = ""
    @Published var bodyFatRate: String = ""
    
    @Published var weightChange: WeightChange? = nil
}

enum WeightChange: String, CaseIterable, Identifiable {
    case none = "변화 없음"
    case gain = "증량"
    case loss = "감량"
    
    var id: Self { self }
}
