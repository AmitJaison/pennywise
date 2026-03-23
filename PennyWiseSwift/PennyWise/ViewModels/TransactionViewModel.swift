// PennyWiseSwift/PennyWise/ViewModels/TransactionViewModel.swift
import Foundation
import SwiftData

struct MonthlySummary {
    var balance: Double
    var totalIncome: Double
    var totalExpenses: Double
}

struct CategoryBreakdown {
    var category: String
    var total: Double
    var percentage: Double
}

@Observable
@MainActor
class TransactionViewModel {
    var modelContext: ModelContext?
    var currentUser: User?

    func setup(modelContext: ModelContext, user: User?) {
        self.modelContext = modelContext
        self.currentUser = user
    }

    // MARK: - Date Helpers

    private func dateRange(for month: Date) -> (start: Date, end: Date) {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: month))!
        let end = cal.date(byAdding: .month, value: 1, to: start)!
        return (start, end)
    }

    // MARK: - Queries

    func transactions(for month: Date) -> [Transaction] {
        guard let modelContext, let user = currentUser else { return [] }
        let (start, end) = dateRange(for: month)
        let uid = user.id
        let descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> { t in
                t.userId == uid && t.date >= start && t.date < end
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func transactions(for month: Date, query: String) -> [Transaction] {
        let all = transactions(for: month)
        guard !query.isEmpty else { return all }
        let lower = query.lowercased()
        return all.filter {
            $0.title.lowercased().contains(lower) || $0.category.lowercased().contains(lower)
        }
    }

    func recentTransactions(limit: Int = 10) -> [Transaction] {
        guard let modelContext, let user = currentUser else { return [] }
        let uid = user.id
        var descriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> { t in t.userId == uid },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Aggregates

    func summary(for month: Date) -> MonthlySummary {
        let txns = transactions(for: month)
        let income = txns.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expenses = txns.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        return MonthlySummary(balance: income - expenses, totalIncome: income, totalExpenses: expenses)
    }

    func categoryBreakdown(for month: Date) -> [CategoryBreakdown] {
        let txns = transactions(for: month).filter { $0.type == .expense }
        let total = txns.reduce(0.0) { $0 + $1.amount }
        guard total > 0 else { return [] }
        var grouped: [String: Double] = [:]
        for t in txns { grouped[t.category, default: 0] += t.amount }
        return grouped.map { cat, amt in
            CategoryBreakdown(category: cat, total: amt, percentage: (amt / total) * 100)
        }.sorted { $0.total > $1.total }
    }

    // MARK: - Mutations

    func add(title: String, amount: Double, type: TransactionType, category: String, date: Date) {
        guard let modelContext, let user = currentUser else { return }
        let t = Transaction(title: title, amount: amount, type: type, category: category, date: date, user: user)
        modelContext.insert(t)
        try? modelContext.save()
    }

    func update(_ transaction: Transaction, title: String, amount: Double,
                type: TransactionType, category: String, date: Date) {
        transaction.title = title
        transaction.amount = amount
        transaction.type = type
        transaction.category = category
        transaction.date = date
        try? modelContext?.save()
    }

    func delete(_ transaction: Transaction) {
        modelContext?.delete(transaction)
        try? modelContext?.save()
    }
}
