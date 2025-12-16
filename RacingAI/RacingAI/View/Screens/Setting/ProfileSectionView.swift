import SwiftUI

struct ProfileSectionView: View {
    
    @EnvironmentObject private var userSession: UserSessionStore
    @State private var showLogin = false
    
    var body: some View {
        Group {
            if let user = userSession.user {
                loggedInView(user: user)
            } else {
                loggedOutView
            }
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

private extension ProfileSectionView {
    func loggedInView(user: User) -> some View {
        HStack(spacing: 10) {
            AsyncImage(url: profileImageURL) { image in
                image.resizable()
            } placeholder: {
                Circle().fill(Color(.systemGray5))
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text(user.name)
                    .font(.callout)
                    .fontWeight(.medium)
                
                Text(user.username)
                    .font(.caption)
            }
            
            Spacer()
        }
    }
}

private extension ProfileSectionView {

    var loggedOutView: some View {
        NavigationLink {
            LoginView()
        } label: {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundStyle(.white.opacity(0.8))
                    )

                VStack(alignment: .leading, spacing: 5) {
                    Text("로그인이 필요합니다")
                        .font(.callout)
                        .fontWeight(.medium)

                    Text("탭하여 로그인하기")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("Chevron"))
            }
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    ProfileSectionView()
        .environmentObject(UserSessionStore())
}
