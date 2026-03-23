import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = TransactionViewModel()
    @State private var selectedMonth = Date()
    @State private var showForm = false
    @State private var editingTransaction: Transaction? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    MonthPickerView(selectedMonth: $selectedMonth)
                    ExpenseSummaryView(summary: viewModel.summary(for: selectedMonth))
                    RecentTransactionsView(
                        transactions: viewModel.recentTransactions(),
                        onEdit: { t in editingTransaction = t; showForm = true },
                        onDelete: { viewModel.delete($0) }
                    )
                }
                .padding(.vertical)
            }
            .navigationTitle("PennyWise")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let name = appState.currentUser?.name {
                        Text("Hi, \(name)!").font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button { editingTransaction = nil; showForm = true } label: {
                            Image(systemName: "plus.circle.fill").font(.title3)
                        }
                        Button("Sign Out") { appState.signOut() }
                            .font(.footnote).foregroundStyle(.red)
                    }
                }
            }
            .sheet(isPresented: $showForm, onDismiss: { editingTransaction = nil }) {
                TransactionFormSheet(viewModel: viewModel, editingTransaction: editingTransaction)
            }
        }
        .onAppear { viewModel.setup(modelContext: modelContext, user: appState.currentUser) }
    }
}
