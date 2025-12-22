import SwiftUI

struct CDDateWeatherBarView: View {
    let dateText: String
    let todayText: String
    let weatherText: String
    
    var body: some View {
        HStack {
            Text(dateText)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(todayText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(weatherText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    CDDateWeatherBarView(dateText: "11월 3일 오늘", todayText: "오늘", weatherText: "맑음 22C")
}
