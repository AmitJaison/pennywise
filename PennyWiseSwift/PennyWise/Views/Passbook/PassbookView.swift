import SwiftUI

struct PassbookView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = TransactionViewModel()
    @State private var selectedMonth = Date()
    @State private var searchQuery = ""
    @State private var showImport = false
    @State private var editingTransaction: Transaction? = nil
    @State private var showEditForm = false

    var filteredTransactions: [Transaction] {
        viewModel.transactions(for: selectedMonth, query: searchQuery)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MonthPickerView(selectedMonth: $selectedMonth).padding(.vertical, 8)
                List {
                    if filteredTransactions.isEmpty {
                        ContentUnavailableView("No Transactions", systemImage: "tray",
                            description: Text(searchQuery.isEmpty ?
                                "No transactions for this month" : "No results for \"\(searchQuery)\""))
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredTransactions) { transaction in
                            TransactionRowView(transaction: transaction)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) { viewModel.delete(transaction) } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    Button { editingTransaction = transaction; showEditForm = true } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }.tint(.blue)
                                }
                        }
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchQuery, prompt: "Search by title or category")
            }
            .navigationTitle("Passbook")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showImport = true } label: { Image(systemName: "square.and.arrow.down") }
                }
            }
            .sheet(isPresented: $showImport) { ImportView(transactionViewModel: viewModel) }
            .sheet(isPresented: $showEditForm, onDismiss: { editingTransaction = nil }) {
                TransactionFormSheet(viewModel: viewModel, editingTransaction: editingTransaction)
            }
        }
        .onAppear { viewModel.setup(modelContext: modelContext, user: appState.currentUser) }
    }
}
