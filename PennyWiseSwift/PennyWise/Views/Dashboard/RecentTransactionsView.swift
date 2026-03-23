import SwiftUI

struct RecentTransactionsView: View {
    let transactions: [Transaction]
    let onEdit: (Transaction) -> Void
    let onDelete: (Transaction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Transactions").font(.headline).padding(.horizontal)

            if transactions.isEmpty {
                ContentUnavailableView("No Transactions", systemImage: "tray",
                    description: Text("Tap + to add your first transaction"))
            } else {
                ForEach(transactions) { transaction in
                    TransactionRowView(transaction: transaction)
                        .padding(.horizontal)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) { onDelete(transaction) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button { onEdit(transaction) } label: {
                                Label("Edit", systemImage: "pencil")
                            }.tint(.blue)
                        }
                }
            }
        }
    }
}
