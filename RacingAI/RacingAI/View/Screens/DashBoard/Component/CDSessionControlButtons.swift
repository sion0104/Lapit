import SwiftUI

struct CDSessionControlButtons: View {
    
    let status: CyclingRideViewModel.RideStatus
    
    let onStart: () -> Void
    let onPauseResume: () -> Void
    let onStop: () -> Void
    let onCancelCountdown: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            switch status {
            case .idle:
                iconButton(
                    systemName: "play.fill",
                    accessibilityLable: "라이딩 시작",
                    action: onStart
                )
            case .countingDown(let sec):
                Text("\(sec)")
                    .font(.system(size: 18, weight: .bold))
                    .monospacedDigit()
                    .frame(minWidth: 28)
                
                iconButton(
                    systemName: "xmark",
                    accessibilityLable: "카운트다운 취소",
                    action: onCancelCountdown
                )
            case .running:
                iconButton(
                    systemName: "pause.fill",
                    accessibilityLable: "일시정지",
                    action: onPauseResume
                )
                iconButton(
                    systemName: "stop.fill",
                    accessibilityLable: "중단",
                    action: onStop
                )
            case .paused:
                iconButton(
                    systemName: "play.fill",
                    accessibilityLable: "다시 시작",
                    action: onPauseResume
                )
                iconButton(
                    systemName: "stop.fill",
                    accessibilityLable: "중단",
                    action: onStop
                )
            }
        }
    }
    
    private func iconButton(
        systemName: String,
        accessibilityLable: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 36, height: 36)
                .background(
                    Circle().fill(.circle)
                )
        }
        .accessibilityLabel(accessibilityLable)
    }
}
