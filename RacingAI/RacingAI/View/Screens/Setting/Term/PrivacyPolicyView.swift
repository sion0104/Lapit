import SwiftUI

struct PrivacyPolicyView: View {
    let onBack: () -> Void
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private let termsAPI: TermsAPIProtocol = TermsAPI()
    private let termsId: Int64 = 2

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let errorMessage {
                Spacer()
                VStack(spacing: 10) {
                    Text(errorMessage)
                        .font(.callout)
                        .foregroundStyle(.red)
                    
                    Button("다시 시도") {
                        Task { await fetchTerms() }
                    }
                }
                Spacer()
            } else {
                ScrollView {
                    Text(content)
                        .font(.body)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 5) {
                    Button { onBack() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.black)
                    }
                    
                    Text(title.isEmpty ? "약관" : title)
                        .font(.title3)
                        .foregroundStyle(Color("Chevron"))
                        .fontWeight(.medium)
                }
            }
        }
        .task {
            await fetchTerms()
        }
    }
    
    private func fetchTerms() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let detail = try await termsAPI.fetchTerm(termsId: termsId)
            title = detail.title
            content = detail.content
        } catch {
            errorMessage = "약관을 불러오지 못했어요.\n(\(error.localizedDescription))"
        }
        
        isLoading = false
    }
}

#Preview {
    TermOfUserView(onBack: {})
}
