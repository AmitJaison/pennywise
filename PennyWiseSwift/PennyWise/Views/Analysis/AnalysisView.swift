import SwiftUI

struct AnalysisView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = TransactionViewModel()
    @State private var selectedMonth = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MonthPickerView(selectedMonth: $selectedMonth).padding(.vertical, 8)
                let summary = viewModel.summary(for: selectedMonth)
                let breakdown = viewModel.categoryBreakdown(for: selectedMonth)
                List {
                    Section {
                        row("Total Income", CurrencyFormatter.format(summary.totalIncome), .green)
                        row("Total Expenses", CurrencyFormatter.format(summary.totalExpenses), .red)
                        row("Balance", CurrencyFormatter.format(summary.balance),
                            summary.balance >= 0 ? .blue : .red)
                    }
                    Section("Expenses by Category") {
                        if breakdown.isEmpty {
                            ContentUnavailableView("No Expenses", systemImage: "chart.pie",
                                description: Text("No expense data for this month"))
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(breakdown, id: \.category) { item in
                                HStack {
                                    Text(item.category.capitalized)
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(CurrencyFormatter.format(item.total)).font(.subheadline.bold())
                                        Text(String(format: "%.1f%%", item.percentage))
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Analysis")
        }
        .onAppear { viewModel.setup(modelContext: modelContext, user: appState.currentUser) }
    }

    private func row(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack { Text(label); Spacer(); Text(value).foregroundStyle(color).bold() }
    }
}
