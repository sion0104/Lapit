import SwiftUI

struct CDHeaderBar: View {
    @EnvironmentObject private var userSession: UserSessionStore
    
    let onProfileTap: () -> Void
    let onSettingsTap: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onProfileTap) {
                HStack(spacing: 10) {
                    profileView
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(userSession.user?.name ?? "게스트")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        if userSession.user == nil {
                            Text("탭하여 로그인")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: onSettingsTap) {
                Image(systemName: "gearshape")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(6)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private var profileView: some View {
        let urlString = userSession.user?.profileImgUrl
        
        if let urlString, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholderCircle
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholderCircle
                @unknown default:
                    placeholderCircle
                }
            }
        } else {
            placeholderCircle
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                )
        }
    }

    private var placeholderCircle: some View {
        Circle()
            .foregroundStyle(.circle)
    }
}
