import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.select),
                    Color(.main)
                ],
                startPoint: .top,
                endPoint: .bottom)
            
            Image("Lapit")
                .frame(width: 196, height: 196, alignment: .center)   
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HomeView()
}
