import SwiftUI

struct CDDateWeatherBarView: View {
//    @StateObject private var vm = DateWeatherViewModel()
    @StateObject private var vm = DateWeatherAPIViewModel()


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
        }
        .padding(.vertical, 10)
    }
}
