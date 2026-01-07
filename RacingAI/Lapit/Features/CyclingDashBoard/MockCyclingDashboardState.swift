import Foundation

enum MockCyclingDashboardState {
    static let loggedIn = CyclingDashboardState(
        hasToken: true,
        userName: "김건강님",
        dateText: "11월 3일",
        todayText: "오늘",
        weatherText: "맑음 22°C",
        rideDurationText: "01H 20M 45S",
        distanceText: "-- km",
        distanceGoalHint: "목표까지 --km",
        speedText: "-- km/h",
        paceHint: "5분간 페이스 유지",
        currentBPM: 150,
        previousBPM: 143,
        previousBPMLabel: "2분 전",
        caloriesText: "350",
        conditionTitle: "이번 주 컨디션",
        conditionLevelText: "주의",
        conditionDesc: "기분 저조함\n컨디션 좋음",
        exerciseScoreTitle: "운동점수",
        exerciseScoreValue: 85,
        exerciseScoreLabel: "높음",
        exerciseScoreDesc: "잘 하고 있어요!",
        avgExerciseTitle: "평균 운동시간",
        avgExerciseTimeText: "4시간 30분",
        avgExerciseDesc: "지난주보다 1시간 더\n운동했습니다."
    )
    
    static let loggedOut = CyclingDashboardState(
        hasToken: false,
        userName: "게스트",
        dateText: "오늘",
        todayText: "오늘",
        weatherText: "날씨 정보 없음",
        rideDurationText: "00H 00M 00S",
        distanceText: "-- km",
        distanceGoalHint: "목표까지 --km",
        speedText: "-- km/h",
        paceHint: "페이스 정보 없음",
        currentBPM: 0,
        previousBPM: 0,
        previousBPMLabel: "",
        caloriesText: "-- kcal",
        conditionTitle: "이번 주 컨디션",
        conditionLevelText: "-",
        conditionDesc: "로그인이 필요합니다.",
        exerciseScoreTitle: "운동점수",
        exerciseScoreValue: 0,
        exerciseScoreLabel: "-",
        exerciseScoreDesc: "로그인이 필요합니다.",
        avgExerciseTitle: "평균 운동시간",
        avgExerciseTimeText: "--",
        avgExerciseDesc: "로그인이 필요합니다."
    )
}
