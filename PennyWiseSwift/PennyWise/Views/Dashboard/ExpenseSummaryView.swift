import SwiftUI

struct ExpenseSummaryView: View {
    let summary: MonthlySummary

    var body: some View {
        HStack(spacing: 0) {
            item(title: "Balance", amount: summary.balance, color: summary.balance >= 0 ? .blue : .red)
            Divider().frame(height: 40)
            item(title: "Income", amount: summary.totalIncome, color: .green)
            Divider().frame(height: 40)
            item(title: "Expenses", amount: summary.totalExpenses, color: .red)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private func item(title: String, amount: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(CurrencyFormatter.format(amount))
                .font(.system(.subheadline, design: .rounded).bold())
                .foregroundStyle(color).lineLimit(1).minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
    }
}
