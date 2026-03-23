import SwiftUI

struct MonthPickerView: View {
    @Binding var selectedMonth: Date

    private var label: String {
        selectedMonth.formatted(.dateTime.month(.wide).year())
    }

    var body: some View {
        HStack {
            Button {
                selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
            } label: { Image(systemName: "chevron.left").foregroundStyle(.blue) }

            Text(label).font(.headline).frame(minWidth: 160)

            Button {
                selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
            } label: { Image(systemName: "chevron.right").foregroundStyle(.blue) }
        }
        .padding(.horizontal)
    }
}
