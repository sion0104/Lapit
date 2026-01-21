import SwiftUI

struct CDMetricGrid: View {
    let distanceText: String
    let distanceHint: String
    
    let speedText: String
    let paceHint: String
    
    let currentBPM: Int
    let previousBPM: Int
    let previousLabel: String
    let bpmDeltaText: String
    
    let caloriesText: String
    
    var body: some View {
        VStack(spacing: 20) {
            CDCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("주행거리 및 속도")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("현재 주행거리")
                            .font(.caption)
                        HStack {
                            Text(distanceText)
                                .font(.title3)
                                .monospacedDigit()
                        }
                    }

                    Divider()
                        .foregroundStyle(Color("Button"))
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("현재 속도")
                            .font(.caption)
                        HStack {
                            Text(speedText)
                                .font(.title3)
                                .monospacedDigit()
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(.white)
            )
            
            GeometryReader { geo in
                let total = geo.size.width
                let leftW = total * 0.6
                let rightW = total * 0.4

                HStack(spacing: 10) {
                    CDCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "heart")
                                    .font(.system(.title3, design: .rounded))
                                Text("현재")
                                    .font(.subheadline)
                            }

                            HStack(alignment: .firstTextBaseline, spacing: 5) {
                                Text("\(currentBPM)")
                                    .font(.system(size: 32, weight: .bold))
                                    .monospacedDigit()
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .allowsTightening(true)
                                    .layoutPriority(1)

                                Text("BPM")
                                    .font(.subheadline)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)

                            if !previousLabel.isEmpty {
                                VStack(alignment: .leading) {
                                    Text(previousLabel)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Text("\(previousBPM) BPM")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                Text("이전 BPM 없음")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                    }
                    .frame(width: leftW)
                    .frame(maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(.white)
                    )

                    CDCard {
                        VStack(alignment: .leading) {
                            Text("소모 칼로리")
                                .font(.subheadline)

                            Spacer(minLength: 0)

                            VStack(alignment: .trailing) {
                                Text(caloriesText)
                                    .font(.system(size: 32, weight: .bold))
                                    .monospacedDigit()
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .allowsTightening(true)

                                Text("kcal")
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                        }
                        .padding() // ✅ 각 카드 padding
                    }
                    .frame(width: rightW)
                    .frame(maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(.white)
                    )
                }
            }
            .frame(height: 150)
        }
        .padding()
    }
}

#Preview {
    CDMetricGrid(distanceText: MockCyclingDashboardState.loggedIn.distanceText, distanceHint: MockCyclingDashboardState.loggedIn.distanceGoalHint, speedText: MockCyclingDashboardState.loggedIn.speedText, paceHint: MockCyclingDashboardState.loggedIn.paceHint, currentBPM: MockCyclingDashboardState.loggedIn.currentBPM, previousBPM: MockCyclingDashboardState.loggedIn.previousBPM, previousLabel: MockCyclingDashboardState.loggedIn.previousBPMLabel, bpmDeltaText: MockCyclingDashboardState.loggedIn.bpmDeltaText, caloriesText: MockCyclingDashboardState.loggedIn.caloriesText)
}
