import SwiftUI

struct CDSessionHeroCard: View {
    let durationText: String
    let status: CyclingRideViewModel.RideStatus
    
    let onStart: () -> Void
    let onPauseResume: () -> Void
    let onStop: () -> Void
    let onCancelCountdown: () -> Void
    
    var body: some View {
        CDCard() {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Text(durationText)
                        .font(.system(size: 20, weight: .bold))
                        .monospacedDigit()
                    
                    Spacer()
                    
                    CDSessionControlButtons(
                        status: status,
                        onStart: onStart,
                        onPauseResume: onPauseResume,
                        onStop: onStop,
                        onCancelCountdown: onCancelCountdown
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 100, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.white),
                            Color("Gradient")
                        ], startPoint: .bottom, endPoint: .top
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 100, style: .continuous)
                .stroke(Color.white, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    CDSessionHeroCard(durationText: "01H 02M 03S", status: .running, onStart: {}, onPauseResume: {}, onStop: {}, onCancelCountdown: {})
}


