import SwiftUI

struct LoginRequiredView: View {
    let onLoginTap: () -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.system(size: 34))
                .foregroundStyle(.secondary)
            
            Text("로그인이 필요합니다")
                .font(.title3.weight(.bold))
            
            Text("회원 정보를 불러오려면 로그인해주세요.\n(지금은 UI만 구현된 상태입니다)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onLoginTap) {
                Text("로그인")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.mint)
                    )
                    .foregroundStyle(.white)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 10)
        .padding()
    }
}
