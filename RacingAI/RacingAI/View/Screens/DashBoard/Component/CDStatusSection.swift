import SwiftUI

struct CDStatusSection: View {
    let conditionTitle: String
    let conditionLevelText: String
    let conditionDesc: String
    
    let scoreTitle: String
    let scoreLabel: String
    let scoreValue: Int
    let scoreDesc: String
    
    let avgTitle: String
    let avgTimeText: String
    let avgDesc: String
    
    private let cardSpacing: CGFloat = 10
    private let minCardSize: CGFloat = 180
    private let maxCardSize: CGFloat = 220
    
    private let cardOuterInset: CGFloat = 10
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("현재 내 상태는?")
                .font(.callout.weight(.medium))
            
            GeometryReader { proxy in
                
                let available = proxy.size.width
                
                let visibleCards: CGFloat = 2.35
                let sideInset: CGFloat = 0
                
                // (보이는 카드 수 - 1) 만큼은 카드 간격 필요
                let totalSpacing = cardSpacing * (visibleCards - 1)
                let cardSize = (available - sideInset * 2 - totalSpacing) / visibleCards
                    
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: cardSpacing) {
                        CDCard {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(conditionTitle)
                                    .font(.callout.weight(.medium))
                                
                                Spacer(minLength: 20)
                                    .layoutPriority(1)
                                
                                Text(conditionLevelText)
                                    .font(.system(size: 24, weight: .bold))
                                
                                Spacer(minLength: 0)
                                    .layoutPriority(2)
                                
                                Text(conditionDesc)
                                    .font(.caption)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true) // \n 포함 줄바꿈 “표현” 우선
                                    .minimumScaleFactor(0.8)      // 문장이 길면 글자 축소
                                    .allowsTightening(true)
                                    .layoutPriority(10)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                        .frame(width: cardSize, height: cardSize)
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(.white)
                        )
                        
                        CDCard {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(scoreTitle)
                                    .font(.caption.weight(.medium))
                                    .layoutPriority(1)
                                
                                Spacer(minLength: 0)
                                
                                HStack {
                                    Spacer(minLength: 0)
                                    CDGaugeView(
                                        value: Double(scoreValue) / 100.0,
                                        labelTop: scoreLabel,
                                        mainValueText: "\(scoreValue)"
                                    )
                                    .frame(width: cardSize * 0.65)
                                    Spacer(minLength: 0)
                                }
                                
                                Spacer(minLength: 0)
                                
                                
                                Text(scoreDesc)
                                    .font(.subheadline.weight(.medium))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.9)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                        .frame(width: cardSize, height: cardSize)
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(.white)
                        )
                        
                        CDCard {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(avgTitle)
                                    .font(.caption.weight(.medium))
                                
                                Spacer(minLength: 20)
                                    .layoutPriority(1)
                                
                                Text(avgTimeText)
                                    .font(.system(size: 24, weight: .bold))
                                
                                Spacer(minLength: 0)
                                    .layoutPriority(2)
                                
                                Text(avgDesc)
                                    .font(.caption)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .minimumScaleFactor(0.8)
                                    .allowsTightening(true)
                                    .layoutPriority(10)
                                
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                        .frame(width: cardSize, height: cardSize)
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(.white)
                        )
                    }
                    .padding(.horizontal, sideInset)
                    .padding(.vertical, cardOuterInset)
                }
                .frame(height: cardSize + cardOuterInset * 2)
                .scrollClipDisabled()
            }
            .frame(height: maxCardSize + cardOuterInset * 2)

//                // 컨디션 미측정 카드(버튼)
//            CDCard {
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("오늘\n기분은\n어떠신가요??")
//                        .font(.title3.weight(.medium))
//                        .lineSpacing(3)
//                    
//                    Button {
//                        // UI만: 나중에 측정 플로우 연결
//                    } label: {
//                        Text("측정하기")
//                            .font(.caption.weight(.medium))
//                            .padding(.horizontal, 14)
//                            .padding(.vertical, 10)
//                            .background(
//                                Capsule().fill(Color(.button))
//                            )
//                    }
//                }
//                .padding()
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
        }
    }
}
