import SwiftUI

// MARK: - Main Screen (Screenshot-like)

struct WorkoutDashboardLikeView: View {
    private let dayNumbers = [20, 21, 22, 23, 24, 25]
    @State private var selectedDayIndex: Int = 0
    
    @State private var elapsedText: String = "01H 20M 45S"
    @State private var isPlaying: Bool = true
    
    @State private var score: Int = 85
    
    @State private var feedbackMemo: String = "오늘 작성된 내용이 없습니다"
    
    private let exerciseResultTitle = "Excellent"
    private let exerciseResultDetail = "평균 BPM 150, 파워 데이터 480W\n오늘 운동시간 2H 34M 22S"
    
    private let caloriesValue = "350kcal"
    private let caloriesDetail = "어려운만큼 칼로리를 더 소모했습니다"
    
    private let hrAverage = 148
    private let hrMin = 90
    private let hrMax = 150
    
    private let hrBars: [Double] = [0.25,0.55,0.40,0.70,0.35,0.60,0.42,0.58,0.75,0.50,0.30,0.62,0.48,0.72,0.40,0.55,0.68,0.45]
    
    private let avgSpeed = "65 km/h"
    private let avgSpeedDetail = "(최저 23km/h ~ 최고 29km/h) 사이를 유지 중 입니다"
    
    private let distance = "30 km"
    private let distanceDetail = "이번주 목표까지 10km 남았습니다"
    
    private let conditionTitle = "기분 좋음"
    private let conditionDetail = "컨디션 보통\n좋은 컨디션을 유지하고 있습니다"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                topDateRow
                
                WorkoutScoreGaugeView(
                    score: score,
                    title: "운동 점수",
                    message: "훈련을 잘 하고 있어요!",
                    ringScale: 1.18
                )
                .frame(height: 175)
                .padding(.top, 30)

                // MARK: Feedback Memo
                card {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("피드백 메모")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button {
                                // TODO: memo edit
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Divider()
                            .padding(.horizontal, 2)
                        
                        Text(feedbackMemo)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // MARK: Diagnosis Section
                sectionHeader("운동 진단")
                
                VStack(spacing: 12) {
                    infoCard(
                        title: "오늘 운동 결과",
                        value: exerciseResultTitle,
                        valueStyle: .accent,
                        detail: exerciseResultDetail
                    )
                    
                    infoCard(
                        title: "소모 칼로리",
                        value: caloriesValue,
                        valueStyle: .accent,
                        detail: caloriesDetail
                    )
                }
                
                // MARK: Today Workout Data
                sectionHeader("오늘 운동 데이터")
                
                // Heart Rate Card
                card {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("심박수")
                            .fontWeight(.medium)
                        
                        Divider()
                            .padding(.horizontal, 2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("평균 심박수 \(hrAverage) BPM")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("최고 \(hrMax), 최저 \(hrMin)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        MiniBarChart(values: hrBars)
                            .frame(height: 80)
                        
                        HStack {
                            Text("13:00")
                            Spacer()
                            Text("14:00")
                            Spacer()
                            Text("15:00")
                            Spacer()
                            Text("16:00")
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                }
                
                // Avg Speed
                card {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("평균 주행속도")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(avgSpeed)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        
                        Text(avgSpeedDetail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Distance
                card {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("오늘 주행거리")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(distance)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        
                        Text(distanceDetail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Condition
                card {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("컨디션")
                            .fontWeight(.medium)
                        
                        Text(conditionTitle)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(conditionDetail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("2025년 11월 3일 월요일")
                    .font(.title3)
                    .foregroundStyle(.black)
                    .fontWeight(.bold)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color("Chevron"))
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Top UI Components

private extension WorkoutDashboardLikeView {
    var topDateRow: some View {
        HStack(spacing: 10) {
            ForEach(dayNumbers.indices, id: \.self) { idx in
                let isSelected = selectedDayIndex == idx
                
                Button {
                    selectedDayIndex = idx
                } label: {
                    Text("\(dayNumbers[idx])")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.mint.opacity(0.18) : Color.clear)
                        )
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.mint.opacity(0.55) : Color.black.opacity(0.08), lineWidth: 1)
                        )
                }
                .foregroundStyle(.primary)
            }
        }
    }
    func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
            Spacer()
        }
        .padding(.top, 24)
    }
}

// MARK: - Reusable Cards

private extension WorkoutDashboardLikeView {
    func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))

    }
    
    enum ValueStyle {
        case accent
        case normal
    }
    
    func infoCard(title: String, value: String, valueStyle: ValueStyle, detail: String) -> some View {
        card {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Text(title)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button {
                        // TODO: info
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(.question)
                    }
                }
                
                Divider()
                    .padding(.horizontal, 2)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(valueStyle == .accent ? Color.mint : .primary)
                
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Mini Bar Chart (Heart Rate)

struct MiniBarChart: View {
    var values: [Double]  // 0...1
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let count = max(values.count, 1)
            let spacing: CGFloat = 4
            let barWidth = max(3, (w - CGFloat(count - 1) * spacing) / CGFloat(count))
            
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(values.indices, id: \.self) { i in
                    let v = min(max(values[i], 0), 1)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.red.opacity(0.8))
                        .frame(width: barWidth, height: max(2, h * v))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        WorkoutDashboardLikeView()
    }
}
