import SwiftUI

struct TextFieldStyle: ViewModifier {
    let isFoucused: Bool
    let isError: Bool
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 19)
            .padding(.vertical, 17)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                backgroundColor
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .foregroundStyle(Color(.systemGray2))
    }
}

 
