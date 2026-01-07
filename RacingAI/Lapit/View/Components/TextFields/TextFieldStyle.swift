import SwiftUI

struct TextFieldStyle: ViewModifier {
    let isFoucused: Bool
    let isError: Bool
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(.systemGray6))
            )
            .foregroundStyle(Color(.systemGray2))
    }
}

 
