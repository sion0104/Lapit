import SwiftUI

struct AICoachPlanView: View {
    @EnvironmentObject private var userSession: UserSessionStore
    @StateObject private var vm = AICoachPlanViewModel()
    
    let onBack: () -> Void
    let date: Date
    
    var body: some View {
        Group {
            switch vm.state {
            case .idle, .loading:
                LoadingPlanView(onBack: onBack)
                    .tabBarHidden(true)
                
            case .loaded(let plan):
                PlanResultView(onBack: onBack, plan: plan)
                    .tabBarHidden(true)
                
            case .failed(let message):
                ErrorPlanView(message: message) {
                    Task { await reload() }
                }
                .tabBarHidden(true)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await reload()
        }
    }
    
    private func reload() async {
        guard (userSession.user?.id) != nil else {
            await MainActor.run {
                vm.forceFail("로그인 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.")
            }
            return
        }
    }
}

private struct LoadingPlanView: View {
    @Environment(\.dismiss) private var dismiss
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("내일의 훈련계획을 생성하고 있습니다...")
                    .font(.callout)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)

                
                ProgressView()
            }
            .background() {
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(width: 344, height: 62)
                  .background(Color(red: 0.95, green: 0.95, blue: 0.97))
                  .cornerRadius(100)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 5) {
                        Button {
                            dismiss()
                            onBack() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color("Chevron"))
                        }

                        Text("AI 운동 코칭")
                            .font(.title3)
                            .foregroundStyle(Color("Chevron"))
                            .fontWeight(.medium)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .padding(.top, 10)
    }
}

private struct ErrorPlanView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 28))
            Text("운동 계획을 불러오지 못했어요")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("다시 시도") { onRetry() }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        AICoachPlanView(
            onBack: { },
            date: Date()
        )
        .environmentObject(UserSessionStore())
    }
}
