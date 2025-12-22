import SwiftUI

struct CDHeaderBar: View {
    let userName: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(.gray.opacity(0.25))
                .frame(width: 30, height: 30)
            
            Text(userName)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}
