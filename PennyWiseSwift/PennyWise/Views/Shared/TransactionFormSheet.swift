import SwiftUI

struct TransactionFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: TransactionViewModel
    var editingTransaction: Transaction? = nil

    @State private var title = ""
    @State private var amount = ""
    @State private var type: TransactionType = .expense
    @State private var category = "other"
    @State private var date = Date()

    var canSave: Bool { !title.isEmpty && Double(amount) != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                        .onChange(of: title) { _, new in
                            category = CategoryPredictor.predict(title: new)
                        }
                    TextField("Amount", text: $amount).keyboardType(.decimalPad)
                    Picker("Type", selection: $type) {
                        Text("Expense").tag(TransactionType.expense)
                        Text("Income").tag(TransactionType.income)
                    }.pickerStyle(.segmented)
                    Picker("Category", selection: $category) {
                        ForEach(CategoryPredictor.allCategories, id: \.self) { cat in
                            Text(cat.capitalized).tag(cat)
                        }
                    }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle(editingTransaction == nil ? "Add Transaction" : "Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.disabled(!canSave)
                }
            }
            .onAppear(perform: loadIfEditing)
        }
    }

    private func loadIfEditing() {
        guard let t = editingTransaction else { return }
        title = t.title; amount = String(t.amount)
        type = t.type; category = t.category; date = t.date
    }

    private func save() {
        guard let amt = Double(amount) else { return }
        if let t = editingTransaction {
            viewModel.update(t, title: title, amount: amt, type: type, category: category, date: date)
        } else {
            viewModel.add(title: title, amount: amt, type: type, category: category, date: date)
        }
        dismiss()
    }
}
