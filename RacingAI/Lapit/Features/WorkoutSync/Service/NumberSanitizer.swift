import Foundation

enum NumberSanitizer {

    static func safe(_ value: Double?) -> Double {
        guard let v = value else { return 0 }
        guard v.isFinite else { return 0 }
        return v
    }

    static func round(_ value: Double, scale: Int) -> Double {
        guard scale >= 0 else { return value }
        let p = pow(10.0, Double(scale))
        return (value * p).rounded() / p
    }

    static func clamp(_ value: Double, min: Double, max: Double) -> Double {
        Swift.max(min, Swift.min(max, value))
    }
    
    static func normalize(_ value: Double?,
                          scale: Int,
                          min: Double = 0,
                          max: Double = .greatestFiniteMagnitude) -> Double {
        let v = clamp(safe(value), min: min, max: max)
        return round(v, scale: scale)
    }
}
