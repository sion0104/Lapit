import SwiftUI

struct ButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 19)
            .padding(.vertical, 17)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color("Button"))
            )
            .foregroundStyle(Color(.black))
            .font(.system(.headline))
    }
}
