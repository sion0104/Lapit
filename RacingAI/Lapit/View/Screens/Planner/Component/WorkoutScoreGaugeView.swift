import SwiftUI

struct WorkoutScoreGaugeView: View {
    var score: Int
    var didWorkout: Bool = true

    var title: String = "운동 점수"
    var ringScale: CGFloat = 1.2

    private var displayScoreText: String {
        didWorkout ? "\(score)" : "?"
    }

    private var progress: Double {
        guard didWorkout else { return 0 }
        return min(max(Double(score) / 100.0, 0), 1)
    }

    private let trackColor = Color.black.opacity(0.12)

    private var ringColor: Color {
        guard didWorkout else { return Color(.systemGray4) }
        if score >= 85 { return Color.mint }
        if score >= 70 { return Color.yellow }
        return Color.red
    }

    private var gaugeStroke: AnyShapeStyle {
        AnyShapeStyle(ringColor)
    }

    private var message: String {
        guard didWorkout else {
            return "오늘 훈련을 시작해볼까요?"
        }

        if score >= 85 {
            return "훈련을 잘 하고 있어요!"
        } else if score >= 70 {
            return "페이스가 조금 떨어졌어요"
        } else {
            return "페이스 변동이 커요"
        }
    }

    private var messageColor: Color {
        guard didWorkout else { return Color.mint }
        if score >= 85 { return Color.mint }
        if score >= 70 { return Color.black }
        return Color.black
    }

    private var scoreColor: Color {
        guard didWorkout else { return Color.mint }
        if score >= 85 { return Color.mint }
        if score >= 70 { return Color.black }
        return Color.black
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
                            gaugeStroke,
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                        )
                }
                .scaleEffect(ringScale)
                .animation(.easeOut(duration: 0.8), value: didWorkout ? score : 0)

                VStack(spacing: 10) {
                    Text(title)
                        .font(.system(size: size * 0.1))
                        .foregroundStyle(.black)

                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(displayScoreText)
                            .font(.system(size: size * 0.2, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(scoreColor)

                        Text("점")
                            .font(.system(size: size * 0.2, weight: .bold))
                            .baselineOffset(2)
                            .foregroundStyle(scoreColor)
                    }

                    Text(message)
                        .font(.system(size: size * 0.08))
                        .fontWeight(.medium)
                        .foregroundStyle(messageColor)
                }
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
}

#Preview {
    VStack(spacing: 30) {
        WorkoutScoreGaugeView(score: 85, didWorkout: true)
            .frame(height: 180)

        WorkoutScoreGaugeView(score: 70, didWorkout: true)
            .frame(height: 180)

        WorkoutScoreGaugeView(score: 65, didWorkout: true)
            .frame(height: 180)

        WorkoutScoreGaugeView(score: 0, didWorkout: false)
            .frame(height: 180)
    }
    .padding()
}
