import SwiftUI

struct GenderOptionView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                ZStack {
                    Rectangle()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color("Button"))
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.black)
                    }
                    
                }
                Text(title)
                    .foregroundStyle(.black)
                    .fontWeight(.medium)
                    .font(.callout)
            }
        }
        .buttonStyle(.plain)
    }
}

