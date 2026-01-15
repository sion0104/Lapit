import SwiftUI

struct MonthDayPickerRow: View {
    @Binding var selectedDayIndex: Int
    @State private var monthDays: [Int] = []

    private var calendar: Calendar { .current }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(monthDays.indices, id: \.self) { idx in
                let isSelected = selectedDayIndex == idx

                Button {
                    selectedDayIndex = idx
                } label: {
                    Text("\(monthDays[idx])")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 34, height: 34)
                        .background(
                            Circle().fill(isSelected ? Color.mint.opacity(0.18) : .clear)
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? Color.mint.opacity(0.55) : Color.black.opacity(0.08),
                                    lineWidth: 1
                                )
                        )
                }
                .foregroundStyle(.primary)
            }
        }
        .onAppear { refreshMonthDays() }
        .onChange(of: calendar.component(.month, from: Date())) {
            refreshMonthDays()
        }
    }

    private func refreshMonthDays(baseDate: Date = Date()) {
        let range = calendar.range(of: .day, in: .month, for: baseDate) ?? 1..<2
        monthDays = Array(range)

        if selectedDayIndex < 0 { selectedDayIndex = 0 }
        if selectedDayIndex >= monthDays.count {
            selectedDayIndex = max(0, monthDays.count - 1)
        }
    }

    func selectedDate(baseDate: Date = Date()) -> Date? {
        let day = monthDays.indices.contains(selectedDayIndex) ? monthDays[selectedDayIndex] : nil
        guard let day else { return nil }
        return calendar.date(bySetting: .day, value: day, of: baseDate)
    }
}

