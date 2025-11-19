import SwiftUI

struct ContentView: View {
    
    @State private var userId: String = ""
    
    var body: some View {
        TermsView()
    }
}

#Preview {
    ContentView()
}
