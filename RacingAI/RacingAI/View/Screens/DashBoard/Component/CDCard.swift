import SwiftUI

struct CDCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .shadow(color: Color("Shadow"), radius: 6, x: 0, y: 2)
    }
}
