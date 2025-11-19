import SwiftUI

struct TermsView: View {

    @State private var terms: [GetTermsListRes] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let termsAPI = TermsAPI()

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("약관 불러오는 중...")
                } else if let errorMessage {
                    VStack(spacing: 8) {
                        Text("오류가 발생했습니다.")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Button("다시 시도") {
                            Task { await loadTerms() }
                        }
                        .padding(.top, 8)
                    }
                } else {
                    List(terms) { term in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(term.title)
                                    .font(.headline)
                                if term.required {
                                    Text("(필수)")
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                } else {
                                    Text("(선택)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Text(term.content)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("약관 동의")
            .task {
                await loadTerms()
            }
        }
    }

    private func loadTerms() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await termsAPI.fetchTerms()
            await MainActor.run {
                self.terms = result.sorted { ($0.sort) < ($1.sort) }
                self.isLoading = false
            }
        } catch {
            let message = describeAPIError(error)
            print("❌ [TermsView] \(message)")

            await MainActor.run {
                self.errorMessage = message
                self.isLoading = false
            }
        }
    }
}
