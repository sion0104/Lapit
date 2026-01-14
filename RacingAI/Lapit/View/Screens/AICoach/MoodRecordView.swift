import SwiftUI

struct MoodRecordView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var mood: Double = 50
    @State private var fatigue: Double = 50

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {

                VStack(alignment: .leading, spacing: 8) {
                    Text("오늘 기분을 기록해보세요")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text("컨디션을 내일 운동 계획에 반영합니다")
                        .font(.callout)
                }

                VStack(alignment: .center, spacing: 20) {
                    Text("오늘 기분은 어떤가요?")
                        .font(.callout)
                        .fontWeight(.medium)
                    
                    LabeledScoreSlider(value: $mood)
                }

                VStack(alignment: .center, spacing: 10) {
                    Text("오늘 피로도는 어느 정도인가요?")
                        .font(.callout)
                        .fontWeight(.medium)
                    LabeledScoreSlider(value: $fatigue)
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            BottomConfirmBar {
                // TODO: 저장/전송
                print("mood:", Int(mood), "fatigue:", Int(fatigue))
                dismiss()
            }
        }
        .background(Color.white)
    }
}

// MARK: - Bottom confirm bar
private struct BottomConfirmBar: View {
    let onTap: () -> Void

    var body: some View {
        AppButton(title: "확인", isEnabled: true) {
            
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding()
        }
}

// MARK: - Reusable Slider (0...100)
struct LabeledScoreSlider: View {
    @Binding var value: Double

    var body: some View {
        VStack {
            ScoreSlider(value: $value, range: 0...100)
                .padding(.horizontal, 20)

            HStack {
                Text("매우 나쁨")
                    .font(.caption)
                Spacer()
                Text("매우 좋음")
                    .font(.caption)
            }
        }
    }
}

struct ScoreSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>

    private let trackHeight: CGFloat = 6
    private let thumbSize: CGFloat = 22

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let usableWidth = max(1, width - thumbSize)

            let progress = normalized(value: value, in: range)
            let x = (usableWidth * progress) + (thumbSize / 2)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.capsule))
                    .frame(height: trackHeight)

                Capsule()
                    .fill(Color.mint.opacity(0.35))
                    .frame(width: max(thumbSize / 2, x), height: trackHeight)

                Circle()
                    .fill(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(.selectedCheckBox), location: 0.00),
                                Gradient.Stop(color: Color(.select), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    )
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay(Circle().stroke(Color.profile, lineWidth: 5))
                    .position(x: x, y: trackHeight / 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { g in
                                let clampedX = min(max(g.location.x, thumbSize / 2), width - thumbSize / 2)
                                let newProgress = (clampedX - thumbSize / 2) / usableWidth
                                let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * newProgress
                                value = newValue.rounded()
                            }
                    )
                    .padding(.top, 8)
            }
            .frame(height: max(thumbSize, trackHeight))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        let clampedX = min(max(g.location.x, thumbSize / 2), width - thumbSize / 2)
                        let newProgress = (clampedX - thumbSize / 2) / usableWidth
                        let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * newProgress
                        value = newValue.rounded()
                    }
            )
        }
        .frame(height: 23)
        .accessibilityValue(Text("\(Int(value))"))
    }

    private func normalized(value: Double, in range: ClosedRange<Double>) -> Double {
        let clamped = min(max(value, range.lowerBound), range.upperBound)
        let denom = (range.upperBound - range.lowerBound)
        return denom == 0 ? 0 : (clamped - range.lowerBound) / denom
    }
}

#Preview {
    MoodRecordView()
}
