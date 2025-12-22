import SwiftUI

struct CyclingDashboardView: View {
    @State private var state: CyclingDashboardState = MockCyclingDashboardState.loggedIn
    @State private var showLoginSheet: Bool = false
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    CDHeaderBar(userName: state.userName)
                    
                    VStack {
                        CDCard {
                            CDDateWeatherBarView(
                                dateText: state.dateText,
                                todayText: state.todayText,
                                weatherText: state.weatherText
                            )
                            
                            CDSessionHeroCard(
                                durationText: state.rideDurationText
                            )
                            
                            CDMetricGrid(
                                distanceText: state.distanceText,
                                distanceHint: state.distanceGoalHint,
                                speedText: state.speedText,
                                paceHint: state.paceHint,
                                currentBPM: state.currentBPM,
                                previousBPM: state.previousBPM,
                                previousLabel: state.previousBPMLabel,
                                bpmDeltaText: state.bpmDeltaText,
                                caloriesText: state.caloriesText
                            )
                            
                            Divider()
                                .foregroundStyle(.circle)
                            
                            Button {
                                // 나중에 상세 화면 연결
                            } label: {
                                Text("자세히 보기")
                                    .font(.caption)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 5)
                                    .foregroundColor(.secondaryFont)
                            }
                        }
                        
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color("MainCD"),
                                        Color(.white)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .shadow(color: .shadow, radius: 4, x: 0, y: -2)
                    
                    CDStatusSection(
                        conditionTitle: state.conditionTitle,
                        conditionLevelText: state.conditionLevelText,
                        conditionDesc: state.conditionDesc,
                        scoreTitle: state.exerciseScoreTitle,
                        scoreLabel: state.exerciseScoreLabel,
                        scoreValue: state.exerciseScoreValue,
                        scoreDesc: state.exerciseScoreDesc,
                        avgTitle: state.avgExerciseTitle,
                        avgTimeText: state.avgExerciseTimeText,
                        avgDesc: state.avgExerciseDesc
                    )
                    .padding(.top, 15)
                }
                .padding()
            }
            // 토큰 없으면 오버레이로 로그인 유도(UI만)
            if !state.hasToken {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                
                LoginRequiredView {
                    showLoginSheet = true
                }
            }
        }
        .background(Color("HomeBackground"))
        .sheet(isPresented: $showLoginSheet) {
            // UI만: 임시 로그인 시트
            VStack(spacing: 16) {
                Text("로그인 화면(임시)")
                    .font(.title2.weight(.bold))
                Text("여기서 실제 로그인/토큰 저장을 나중에 붙일 예정입니다.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("로그인 성공(목데이터)") {
                    state = MockCyclingDashboardState.loggedIn
                    showLoginSheet = false
                }
                .buttonStyle(.borderedProminent)
                
                Button("닫기") {
                    showLoginSheet = false
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .presentationDetents([.medium])
        }
        .navigationBarHidden(true)
        .onAppear {
            // 여기서 나중에:
            // - 토큰 확인
            // - 오늘 날짜 문자열 세팅
            // - WeatherKit/HealthKit/백엔드 연동 시작
        }
    }
}

#Preview {
    CyclingDashboardView()
}
