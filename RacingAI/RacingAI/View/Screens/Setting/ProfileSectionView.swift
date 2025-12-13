import SwiftUI

struct ProfileSectionView: View {
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color("Button"))
                .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("김건강")
                    .font(.callout)
                    .fontWeight(.medium)
                
                Text("id")
                    .font(.caption)
            }
            
            Spacer()
        }
        .padding()
        .background(Color("Profile"))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    
    }
}

#Preview {
    ProfileSectionView()
}
