import SwiftUI

struct AICoachView: View {
    let onBack: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var goGenerator = false
    @State private var goMyPlan = false
    
    @State private var checkDateForNav: String = ""
    
    @State private var isChecking = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 375, height: 375)
                    .background(
                        EllipticalGradient(
                            stops: [
                                .init(color: Color(red: 0.18, green: 0.92, blue: 0.71), location: 0.00),
                                .init(color: .white, location: 1.00),
                            ],
                            center: .center
                        )
                    )
                    .opacity(0.1)

                VStack(alignment: .center, spacing: 5) {
                    Image("Bicycle")

                    Text("내일은 어떻게 운동 할까요?")
                        .font(.title3)
                        .fontWeight(.medium)
                        .padding(.top, 20)

                    Text("AI 코치가 내일 운동에 도움을 주는\n계획을 작성합니다")
                        .multilineTextAlignment(.center)
                        .font(.callout)

                    Button {
                        Task { await checkAndNavigate() }
                    } label: {
                        HStack(spacing: 8) {
                            Text(isChecking ? "확인 중..." : "운동 계획하기")
                                .font(.callout)
                                .fontWeight(.medium)
                            if isChecking {
                                ProgressView().scaleEffect(0.9)
                            }
                        }
                    }
                    .disabled(isChecking)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            stops: [
                                .init(color: .white, location: 0.00),
                                .init(color: Color(red: 0.95, green: 0.95, blue: 0.97).opacity(0.7), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 1),
                            endPoint: UnitPoint(x: 0.5, y: 0)
                        )
                    )
                    .cornerRadius(100)
                    .shadow(color: Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0.4), radius: 3, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .inset(by: 0.5)
                            .stroke(.white, lineWidth: 1)
                    )
                    .foregroundStyle(.black)
                    .padding(.top, 21)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .navigationDestination(isPresented: $goMyPlan) {
                MyWorkoutPlanView(checkDate: checkDateForNav)
            }
            .navigationDestination(isPresented: $goGenerator) {
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                AICoachPlanView(onBack: onBack, date: tomorrow)
            }
        }
    }

    private func checkAndNavigate() async {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let checkDate = tomorrow.toYMDLocal()

        await MainActor.run {
            isChecking = true
            errorMessage = nil
            goMyPlan = false
            goGenerator = false
        }

        do {
            let res: CommonResponse<DailyAIPlanPayload> = try await APIClient.shared.fetchDailyAIPlan(checkDate: checkDate)

            guard let planString = res.data.plan, !planString.isEmpty else {
                await MainActor.run {
                    isChecking = false
                    goGenerator = true
                }
                return
            }
            
            let rawMarkdown = normalizeMarkdown(planString)

            let title = "\(tomorrow.monthKorean()) \(tomorrow.day())일 운동 계획"
            let parsed = try WorkoutPlanParser.parse(raw: rawMarkdown, dateTitle: title)
            
            let checklist = buildChecklistItems(from: parsed)
            _ = try DailyPlanLocalStore.upsert(
                checkDate: checkDate,
                parsed: parsed,
                checklist: checklist,
                memo: "",
                context: modelContext
            )

            await MainActor.run {
                isChecking = false
                checkDateForNav = checkDate
                goMyPlan = true
            }

        } catch let apiError as APIError {
            await MainActor.run { isChecking = false }
            if case .serverStatusCode(let statusCode, _) = apiError, statusCode == 404 {
                await MainActor.run {
                    goGenerator = true
                }
                return
            }

            await MainActor.run {
                errorMessage = apiError.userMessage
            }

        } catch {
            await MainActor.run {
                isChecking = false
                errorMessage = error.userMessage
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

    private func normalizeMarkdown(_ raw: String) -> String {
        var text = raw
        text = text.replacingOccurrences(of: "\\n", with: "\n")
        text = text.replacingOccurrences(of: "\r\n", with: "\n")
        text = text.replacingOccurrences(of: "\r", with: "\n")
        return text
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

    func monthKorean() -> String {
        let c = Calendar.current
        return "\(c.component(.month, from: self))월"
    }

    func day() -> Int {
        Calendar.current.component(.day, from: self)
    }
}

#Preview {
    AICoachView(onBack: {})
}
