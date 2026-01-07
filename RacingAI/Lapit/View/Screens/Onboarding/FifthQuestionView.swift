import SwiftUI

struct FifthQuestionView: View {
    @EnvironmentObject var bodyInfoStore: BodyInfoStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var canGoNext = false
    
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var isDone = false
    
    @State private var userId: Int?
    
    private var isNextEnabled: Bool {
        bodyInfoStore.todayCondition != nil
    }
    
    private var isSubmitEnabled: Bool {
        isNextEnabled && userId != nil && !isSubmitting
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    ProgressView(value: 5, total: 5)
                        .tint(Color("MainColor"))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("오늘 컨디션은 어떤가요")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .padding(.bottom, 30)
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(spacing: 10) {
                        ForEach(TodayCondition.allCases) { condition in
                            AppButton(
                                title: condition.title,
                                isEnabled: true,
                                isLeading: true
                            ) {
                                bodyInfoStore.todayCondition = condition
                                }
                            .buttonStyle(SecondaryButtonStyle())
                                .font(.callout)
                                .fontWeight(.medium)
                                .opacity(bodyInfoStore.todayCondition == condition ? 1.0 : 0.7)
                        }
                    }
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.top, 12)
                }
            }
            .padding()
            .safeAreaInset(edge: .bottom) {
                AppButton(
                    title: isSubmitting ? "저장 중.." : "설문 완료",
                    isEnabled: isSubmitEnabled) {
                        guard let userId else {
                            errorMessage = "회원 정보를 불러오지 못했습니다. 다시 시도해주세요."
                            return
                        }
                        submitOnboarding(userId: userId)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding()
            }
            .navigationDestination(isPresented: $canGoNext) {
                CompleteView()
                    .environmentObject(bodyInfoStore)
            }
            .navigationBarBackButtonHidden(true)
            .task {
                await fetchUserIdIfNeeded()
            }
        }
    }
    
    @MainActor
    private func fetchUserIdIfNeeded() async {
        guard userId == nil else { return }
        errorMessage = nil
        
        do {
            let me = try await APIClient.shared.getUserInfo()
            userId = me.id
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func submitOnboarding(userId: Int) {
        guard !isSubmitting else { return }
        errorMessage = nil
        
        guard let req = bodyInfoStore.makeRegisterOnboardReq(userId: userId) else {
            errorMessage = "신체 정보가 올바르지 않습니다."
            return
        }
        
        isSubmitting = true
        Task {
            defer { isSubmitting = false }
            do {
                let res: CommonResponse<UserIdPayload> = try await APIClient.shared.registerOnboard(req)
                print("✅ onboard saved userId:", res.data.userID)
                isDone = true
                canGoNext = true
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    FifthQuestionView()
        .environmentObject(BodyInfoStore())
}
