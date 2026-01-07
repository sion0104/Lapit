import SwiftUI

struct CustomTabBarView: View {
    let tabs: [AppTab]
    @Binding var selection: AppTab
    
    private let selectedColor = Color("SelectColor")
    private let unselectedColor = Color("SecondaryFont")
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                Button {
                   selection = tab
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.systemImage)
                            .font(.title2)
                            .fontWeight(selection == tab ? .bold : .regular)
                        
                        Text(tab.title)
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(selection == tab ? selectedColor : unselectedColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .background(
            TopRoundedRectangle(radius: 20)
                .fill(.white)
                .shadow(color: Color("Circle"), radius: 8, x: 0, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct TopRoundedRectangle: Shape {
    var radius: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

