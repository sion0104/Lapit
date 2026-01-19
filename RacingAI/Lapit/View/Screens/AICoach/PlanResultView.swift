import SwiftUI

struct PlanResultView: View {
    let onBack: () -> Void
    let plan: WorkoutPlan
    let rawMarkdown: String
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var goToMyPlan: Bool = false
    @State private var isSaving: Bool = false
    @State private var saveError: String?
    
    private var checkDate: String {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        return tomorrow.toYMDLocal()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
            
                Text(plan.dateTitle)
                    .font(.title3)
                    .fontWeight(.medium)
                
                VStack (alignment: .leading, spacing: 10){
                                        
                    VStack(alignment: .leading, spacing: 6) {
                        Text(plan.summaryTitle)
                            .font(.title3)
                            .fontWeight(.medium)
                        Text(plan.summaryDescription)
                            .font(.subheadline)
                    }
                }
                .padding()
                
                sectionTitle("운동 내용")
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("목표 지표")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    metricRow(title: "평균 HR", value: plan.avgHRText)
                    metricRow(title: "최고속 구간", value: plan.maxSpeedText)
                    metricRow(title: "Training Efficiency Score 목표", value: plan.tesGoalText)
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("세부 계획")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("워밍업")
                                .font(.subheadline)
                            Text(plan.warmupText)
                                .font(.body)
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("메인")
                                .font(.subheadline)
                            
                            ForEach(plan.mainItems.indices, id: \.self) { idx in
                                Text(plan.mainItems[idx])
                                    .font(.body)
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationBarBackButtonHidden(true)
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 5) {
                    Button {
                        dismiss()
                        onBack()
                    } label: {
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
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color("Chevron"))
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            AppButton(
                title: "내일 플래너에 등록",
                isEnabled: true) {
                    Task { await saveAndGoMyPlan() }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding()
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $goToMyPlan) {
            MyWorkoutPlanView(checkDate: checkDate)
        }
    }
    
    private func saveAndGoMyPlan() async {
        await MainActor.run {
            isSaving = true
            saveError = nil
        }

        let memoToSave = ""
        
        do {
            _ = try await APIClient.shared.saveDailyPlan(
                checkDate: checkDate,
                plan: rawMarkdown,
                memo: memoToSave
            )

            let checklist = buildChecklistItems(from: plan)
            _ = try DailyPlanLocalStore.upsert(
                checkDate: checkDate,
                parsed: plan,
                checklist: checklist,
                memo: memoToSave,
                context: modelContext
            )

            await MainActor.run {
                isSaving = false
                goToMyPlan = true
            }
        } catch {
            await MainActor.run {
                isSaving = false
                saveError = error.userMessage
            }
        }
    }



    private func buildChecklistItems(from plan: WorkoutPlan) -> [PlanCheckItem] {
        var result: [PlanCheckItem] = []
        result.append(.init(text: "워밍업: \(plan.warmupText)", isDone: false))
        for item in plan.mainItems {
            result.append(.init(text: item, isDone: false))
        }
        return result
    }
    
    @ViewBuilder
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title2)
            .fontWeight(.medium)
    }
    
    @ViewBuilder
    private func metricRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}

private extension Date {
    func toYMDLocal() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: self)
    }
}

