import SwiftUI

struct SettingRowView<Destination: View>: View {
    let title: String
    let destination: Destination
    
    init(title: String, destination: Destination) {
        self.title = title
        self.destination = destination
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationLink {
                destination
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
}

#Preview {
    SettingRowView(title: "설정", destination: ProfileSectionView())
}
