import SwiftUI

struct AICoachView: View {
    let onBack: () -> Void
    @State private var goPlan = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(width: 375, height: 375)
                  .background(
                    EllipticalGradient(
                      stops: [
                        Gradient.Stop(color: Color(red: 0.18, green: 0.92, blue: 0.71), location: 0.00),
                        Gradient.Stop(color: .white, location: 1.00),
                      ],
                      center: UnitPoint(x: 0.5, y: 0.5)
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
                    
                    Button(action: {
                        goPlan = true
                    }, label: {
                        Text("운동 계획하기")
                            .font(.callout)
                            .fontWeight(.medium)
                    })
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                      LinearGradient(
                        stops: [
                          Gradient.Stop(color: .white, location: 0.00),
                          Gradient.Stop(color: Color(red: 0.95, green: 0.95, blue: 0.97).opacity(0.7), location: 1.00),
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
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 5) {
                        Button { onBack() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color("Chevron"))
                        }

                        Text("AI 운동 코칭")
                            .font(.title3)
                            .foregroundStyle(.black)
                            .fontWeight(.medium)
                    }
                }
            }
            .navigationDestination(isPresented: $goPlan) {
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!

                AICoachPlanView(
                    onBack: onBack, date: tomorrow
                )
            }
        }
    }
}

#Preview {
    AICoachView(onBack: {})
}
