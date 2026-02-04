import SwiftUI

struct SettingSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color("SecondaryFont"))

            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}
