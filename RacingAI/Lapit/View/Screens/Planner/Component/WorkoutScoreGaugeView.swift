import SwiftUI

struct WorkoutScoreGaugeView: View {
    var score: Int
    
    var title: String = "운동 점수"
    var message: String = "훈련을 잘 하고 있어요!"

    var ringScale: CGFloat = 1.2
    
    private var progress: Double {
        min(max(Double(score) / 100.0, 0), 1)
    }
    
    private let trackColor = Color.black.opacity(0.12)
    
    private var gaugeGradient: LinearGradient {
        switch score {
        case ..<70:
            return LinearGradient(
                stops: [
                    .init(color: Color(red: 0.20, green: 0.62, blue: 1.00), location: 0.00),
                    .init(color: Color(red: 0.16, green: 0.80, blue: 0.62), location: 1.00),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
        case 70...85:
            return LinearGradient(
                stops: [
                    .init(color: Color(red: 0.16, green: 0.80, blue: 0.62), location: 0.00),
                    .init(color: Color(red: 0.18, green: 0.90, blue: 0.70), location: 1.00),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
        default:
            return LinearGradient(
                stops: [
                    .init(color: Color(red: 0.13, green: 0.95, blue: 0.75), location: 0.00),
                    .init(color: Color(red: 0.25, green: 1.00, blue: 0.65), location: 1.00),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let lineWidth = max(10, size * 0.10)
            
            ZStack {
                ZStack {
                    Circle()
                        .trim(from: 0.5, to: 1.0)
                        .stroke(
                            trackColor,
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                        )
                    
                    Circle()
                        .trim(from: 0.5, to: 0.5 + progress * 0.5)
                        .stroke(
                            gaugeGradient,
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                        )
                }
                .scaleEffect(ringScale)
                .animation(.easeOut(duration: 0.8), value: score)
                
                VStack(spacing: 10) {
                    Text(title)
                        .font(.system(size: size * 0.07))
                        .foregroundStyle(.black)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(score)")
                            .font(.system(size: size * 0.2, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(gaugeGradient)
                        
                        Text("점")
                            .font(.system(size: size * 0.2, weight: .bold))
                            .foregroundStyle(gaugeGradient)
                            .baselineOffset(2)
                    }
                    
                    Text(message)
                        .font(.system(size: size * 0.08))
                        .fontWeight(.medium)
                        .foregroundStyle(gaugeGradient)
                }
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
}

#Preview {
    WorkoutScoreGaugeView(score: 85)
}
