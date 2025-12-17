import SwiftUI

struct SettingRowButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack {
                    Text(title)
                        .font(.callout)
                        .foregroundStyle(.black)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color("Chevron"))
                }
                .padding()
            }

            Divider()
                .padding(.leading)
        }
    }
}
