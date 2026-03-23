import SwiftUI

struct ImportView: View {
    let transactionViewModel: TransactionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ContentUnavailableView("Import Coming Soon", systemImage: "doc.badge.plus")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                }
        }
    }
}
