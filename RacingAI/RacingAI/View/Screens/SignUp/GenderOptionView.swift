import SwiftUI

struct GenderOptionView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                AppCheckBox(isOn: .constant(isSelected), size: 24, isTapEnabled: false)
                Text(title)
                    .foregroundStyle(.black)
                    .fontWeight(.medium)
                    .font(.callout)
            }
        }
        .buttonStyle(.plain)
    }
}

