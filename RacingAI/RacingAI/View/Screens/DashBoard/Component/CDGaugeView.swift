import SwiftUI

struct CDGaugeView: View {
    var value: Double          // 0...1
    var labelTop: String       // 예: "높음"
    var mainValueText: String  // 예: "85"
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                let w = geo.size.width
                let line = max(6, w * 0.08)
                
                Circle()
                    .trim(from: 0.5, to: 1.0)
                    .stroke(
                        .black.opacity(0.10),
                        style: StrokeStyle(lineWidth: line, lineCap: .round)
                    )
                
                Circle()
                    .trim(from: 0.5, to: 0.5 + min(max(value, 0), 1) * 0.5)
                    .stroke(
                        .mint,
                        style: StrokeStyle(lineWidth: line, lineCap: .round)
                    )
                
                VStack {
                    Text(labelTop)
                        .font(.footnote)
                        .foregroundStyle(.mint)
                    
                    Text(mainValueText)
                        .font(.system(size: max(20, w * 0.38), weight: .bold))
                        .monospacedDigit()
                }
            }
            .rotationEffect(.degrees(0))
        }
        .aspectRatio(1.1, contentMode: .fit)
    }
}

#Preview {
    CDGaugeView(value: 85, labelTop: "높음", mainValueText: "85")
}
