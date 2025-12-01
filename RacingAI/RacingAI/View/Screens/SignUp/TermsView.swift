import SwiftUI

struct TermsView: View {
    @EnvironmentObject var store: UserInfoStore
    @Environment(\.dismiss) private var dismiss

    @State private var terms: [GetTermsListRes] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let termsAPI = TermsAPI()
    
    @State private var expandedIds: Set<Int> = []
    @State private var showValidationAlert = false
    
    private var requiredTermsIds: [Int] {
        terms.filter { $0.required }.map { $0.id }
    }
    
    private var canGoNext: Bool {
        store.areAllRequiredAgreed(requiredTermIds: requiredTermsIds)
    }
    
    private var canComplete: Bool {
        store.areAllRequiredAgreed(requiredTermIds: requiredTermsIds)
    }
    
    private var isAllAgreed: Bool {
        guard !terms.isEmpty else { return false }
        return terms.allSatisfy { store.isAgreed(termId: $0.id) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("약관 불러오는 중...")
                } else if let errorMessage {
                    errorView(errorMessage)
                } else {
                    contentView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .task { await loadTerms() }
        }
        .safeAreaInset(edge: .bottom) {
            BottomBar(
                leftTitle: "뒤로 가기",
                rightTitle: "다음 단계",
                leftAction: {
                    dismiss()
                },
                rightAction: {
                    if canGoNext {
                        dismiss()
                    } else {
                        showValidationAlert = true
                    }
                })
        }
        .alert("약관 동의 필요", isPresented: $showValidationAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("필수 약관에 모두 동의해야 다음 단계로 진행할 수 있어요.")
        }
    }
}

private extension TermsView {
    var contentView: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("가입을 위해 약관 동의가 필요합니다.")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top, 40)
            }
            
            allAgreeRow
                .padding(.vertical, 20)
            
            Divider()
                .padding(.bottom, 20)
                .foregroundStyle(.black)
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(terms) { term in
                        termRow(term)
                            .padding(.vertical, 5)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    var allAgreeRow: some View {
        HStack {
            AppCheckBox(
                isOn:
                    Binding (
                        get: { isAllAgreed },
                        set: { newValue in
                            terms.forEach { term in
                                store.setAgreed(termId: term.id, isOn: newValue)
                            }
                        }
                    ),
                size: 22
            )
            
            Text("약관 전체 동의 (선택항목 포함)")
                .fontWeight(.medium)
            
            Spacer()
        }
    }
    
    func termRow(_ term: GetTermsListRes) -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                AppCheckBox(
                    isOn: Binding(
                        get: { store.isAgreed(termId: term.id) },
                        set: { store.setAgreed(termId: term.id, isOn: $0)}
                    )
                )
                
                VStack(alignment: .leading) {
                    Button {
                        toggleExpand(term.id)
                    } label: {
                        HStack {
                            Text(labelTitle(for: term))
                                .font(.callout)
                            
                            Spacer()
                            
                            Image(systemName: expandedIds.contains(term.id) ? "chevron.up" : "chevron.down")
                                .font(.system(size: 13))
                                .foregroundStyle(.gray)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    if expandedIds.contains(term.id) {
                        Text(term.content)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.top, 2)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    func labelTitle(for term: GetTermsListRes) -> String {
        term.required ? "[필수] \(term.title)" : "[선택] \(term.title)"
    }
    
    func toggleExpand(_ id: Int) {
        if expandedIds.contains(id) {
            expandedIds.remove(id)
        } else {
            expandedIds.insert(id)
        }
    }
    
    func errorView(_ message: String) -> some View {
        VStack {
            Text("오류가 발생했습니다.")
                .font(.headline)
            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button("다시 시도") {
                Task { await loadTerms() }
            }
        }
    }
}

private extension TermsView {
    func loadTerms() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await termsAPI.fetchTerms()
            await MainActor.run {
                self.terms = result.sorted { $0.sort < $1.sort }
                
                for term in self.terms {
                    if store.agreedTerms[term.id] == nil {
                        store.agreedTerms[term.id] = false
                    }
                }
                
                self.isLoading = false
            }
        } catch {
            let message = describeAPIError(error)
            print("ERROR: TermsView \(message)")
            await MainActor.run {
                self.errorMessage = message
                self.isLoading = false
            }
        }
    }
}

#Preview {
    TermsView()
        .environmentObject(UserInfoStore())
}

