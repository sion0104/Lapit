import SwiftUI

struct HeartRatePillChart: View {
    let values: [Double]          // 0...1
    let maxLabel: String          // 우측 상단(예: "200")
    let xLabels: [String]         // 하단 라벨(예: ["13:00","14:00","15:00","16:00"])

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    let count = max(values.count, 1)

                    // 스타일: 사진처럼 간격 넓고 굵은 바
                    let spacing: CGFloat = 7
                    let barWidth = max(8, (w - CGFloat(count - 1) * spacing) / CGFloat(count))

                    // 가이드 라인
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: 0))
                        p.addLine(to: CGPoint(x: w, y: 0))
                    }
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)

                    Path { p in
                        p.move(to: CGPoint(x: 0, y: h * 0.55))
                        p.addLine(to: CGPoint(x: w, y: h * 0.55))
                    }
                    .stroke(Color.black.opacity(0.08), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))

                    HStack(alignment: .bottom, spacing: spacing) {
                        ForEach(values.indices, id: \.self) { i in
                            let v = min(max(values[i], 0), 1)

                            Capsule()
                                .fill(Color.black.opacity(0.92))
                                .frame(
                                    width: barWidth,
                                    height: max(10, h * (0.18 + 0.82 * v))
                                )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
                .frame(height: 90)

                Text(maxLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }

            HStack {
                ForEach(xLabels.indices, id: \.self) { i in
                    Text(xLabels[i])
                    if i != xLabels.count - 1 { Spacer() }
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }
}
