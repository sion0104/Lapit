import SwiftUI

struct CDDateWeatherBarView: View {
    @StateObject private var vm = DateWeatherViewModel()

    var body: some View {
        HStack {
            Text(vm.dateText)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(vm.todayText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(vm.weatherText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .task {
            await vm.onAppear()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            vm.refreshDateOnly()
            Task { await vm.refreshWeather() }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task { await vm.refreshWeather() }
        }
        .padding(.vertical, 10)
    }
}
