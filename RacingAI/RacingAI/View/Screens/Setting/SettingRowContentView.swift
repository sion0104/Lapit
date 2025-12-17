import SwiftUI

struct SettingRowContentView: View {
    let title: String

    var body: some View {
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
}
