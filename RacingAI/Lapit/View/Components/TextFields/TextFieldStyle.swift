import SwiftUI

struct TextFieldStyle: ViewModifier {
    let isFoucused: Bool
    let isError: Bool
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .frame(maxWidth: 342, alignment: .leading)
            .background(
                backgroundColor
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .foregroundStyle(Color(.systemGray2))
    }
}

 
