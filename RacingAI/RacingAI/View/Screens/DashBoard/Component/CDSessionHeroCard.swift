import SwiftUI

struct CDSessionHeroCard: View {
    let durationText: String
    
    var body: some View {
        CDCard() {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Text(durationText)
                        .font(.system(size: 20, weight: .bold))
                        .monospacedDigit()
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Circle().fill(Color("Circle")).frame(width: 23.54, height: 23.54)
                        Circle().fill(Color("Circle")).frame(width: 23.54, height: 23.54)
                    }
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
    }
}

#Preview {
    CDSessionHeroCard(durationText: "01H 20M 45S")
        .frame(width: 289, height: 68.75)
}
