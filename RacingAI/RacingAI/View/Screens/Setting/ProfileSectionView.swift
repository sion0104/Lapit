import SwiftUI

struct ProfileSectionView: View {
    
    @EnvironmentObject private var userSession: UserSessionStore
    
    var body: some View {
        HStack(spacing: 10) {
            AsyncImage(url: profileImageURL) { image in
                image.resizable()
            } placeholder: {
                Circle().fill(Color(.systemGray5))
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text(userSession.user?.name ?? "-")
                    .font(.callout)
                    .fontWeight(.medium)
                
                Text(userSession.user?.id ?? "")
                    .font(.caption)
            }
            
            Spacer()
        }
        .padding()
        .background(Color("Profile"))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    
    }
    
    private var profileImageURL: URL? {
        guard let urlString = userSession.user?.profileImgUrl else { return nil }
        return URL(string: urlString)
    }
}

#Preview {
    ProfileSectionView()
        .environmentObject(UserSessionStore())
}
