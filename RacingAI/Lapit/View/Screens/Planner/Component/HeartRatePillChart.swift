import SwiftUI

struct HeartRatePillChart: View {
    let values: [Double]          // 0...1
    let maxLabel: String
    let minLabel: String
    let xLabels: [String]

    var upperPercentile: Double = 0.90

    private var maxValueInt: Int { Int(maxLabel) ?? 0 }
    private var minValueInt: Int { Int(minLabel) ?? 0 }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height

                    let spacing: CGFloat = 7
                    let minBarWidth: CGFloat = 3

                    let labelFont = UIFont.systemFont(ofSize: 11)
                    let maxW = textWidth(maxLabel, font: labelFont)
                    let minW = textWidth(minLabel, font: labelFont)
                    let labelW = max(maxW, minW)

                    let trailingPadding = labelW + 8
                    let chartW = max(0, w - trailingPadding)

                    let maxBars = max(1, Int(floor((chartW + spacing) / (minBarWidth + spacing))))

                    let p = min(max(upperPercentile, 0), 1)
                    let displayValues = downsampleUpperPercentile(values: values, targetCount: maxBars, p: p)
                    let count = max(displayValues.count, 1)

                    // ✅ 캡슐 폭을 2 줄이기
                    let rawBarWidth = (chartW - CGFloat(count - 1) * spacing) / CGFloat(count)
                    let barWidth = max(minBarWidth, rawBarWidth - 2)


                    // 상단/하단 라인
                    Path { p in
                        p.move(to: .init(x: 0, y: 0))
                        p.addLine(to: .init(x: chartW, y: 0))
                    }
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)

                    Text("\(maxValueInt)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .position(x: chartW + labelW / 2 + 4, y: 1)

                    Path { p in
                        p.move(to: .init(x: 0, y: h))
                        p.addLine(to: .init(x: chartW, y: h))
                    }
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)

                    Text("\(minValueInt)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .position(x: chartW + labelW / 2 + 4, y: h - 1)

                    // 캡슐
                    ZStack(alignment: .topLeading) {
                        ForEach(displayValues.indices, id: \.self) { i in
                            let v = min(max(displayValues[i], 0), 1)

                            // 선과의 안전 여백
                            let lineGap: CGFloat = 6
                            let topLimit = lineGap
                            let bottomLimit = h - lineGap

                            // 캡슐 높이 제한 (절대 선을 넘지 않게)
                            let maxAllowedPillH = max(10, bottomLimit - topLimit)

                            // 원래 계산된 높이
                            let rawPillH = h * (0.18 + 0.82 * v)

                            // ✅ 최종 캡슐 높이
                            let pillH = min(max(10, rawPillH), maxAllowedPillH)

                            // 위치 계산
                            let usableH = bottomLimit - topLimit
                            let rawCenterY = topLimit + (1 - v) * usableH

                            // centerY도 최종 안전 클램프
                            let minCenterY = topLimit + pillH / 2
                            let maxCenterY = bottomLimit - pillH / 2
                            let yCenter = min(max(rawCenterY, minCenterY), maxCenterY)


                            // x 좌표는 “줄어든 barWidth” 기준으로 중앙에 맞춤
                            let x = CGFloat(i) * (barWidth + spacing) + barWidth / 2

                            Capsule()
                                .fill(Color.heartRate)
                                .frame(width: barWidth, height: pillH)
                                .position(x: x, y: yCenter)
                        }
                    }
                    .frame(width: chartW, height: h, alignment: .topLeading)
                }
                .frame(height: 90)
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

    private func textWidth(_ text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        return (text as NSString).size(withAttributes: attributes).width
    }

    private func downsampleUpperPercentile(values: [Double], targetCount: Int, p: Double) -> [Double] {
        guard targetCount > 0 else { return [] }
        guard values.count > targetCount else { return values }

        let n = values.count
        let step = Double(n) / Double(targetCount)

        return (0..<targetCount).map { i in
            let start = Int(floor(Double(i) * step))
            let end = Int(floor(Double(i + 1) * step))

            let s = min(max(start, 0), n - 1)
            let e = min(max(end, s + 1), n)

            let chunk = Array(values[s..<e]).map { min(max($0, 0), 1) }
            guard !chunk.isEmpty else { return 0 }

            let sorted = chunk.sorted()
            let idx = p * Double(sorted.count - 1)
            let lo = Int(floor(idx))
            let hi = Int(ceil(idx))

            if lo == hi { return sorted[lo] }

            let w = idx - Double(lo)
            let v = sorted[lo] * (1 - w) + sorted[hi] * w
            return min(max(v, 0), 1)
        }
    }
}
