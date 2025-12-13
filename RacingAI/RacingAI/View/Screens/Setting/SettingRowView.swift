import SwiftUI

struct SettingRowView: View {
    let title: String
    
    var body: some View {
        NavigationLink {
            Text(title)
        } label: {
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

#Preview {
    SettingRowView(title: "설정")
}
