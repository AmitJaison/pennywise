// PennyWiseSwift/PennyWiseTests/TransactionViewModelTests.swift
import XCTest
import SwiftData
@testable import PennyWise

@MainActor
final class TransactionViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var viewModel: TransactionViewModel!
    var user: User!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: User.self, Transaction.self, configurations: config)
        context = ModelContext(container)
        user = User(name: "Amit", email: "amit@test.com")
        context.insert(user)
        try context.save()
        viewModel = TransactionViewModel()
        viewModel.setup(modelContext: context, user: user)
    }

    func test_add_createsTransaction() {
        viewModel.add(title: "Zomato", amount: 250, type: .expense, category: "food", date: Date())
        XCTAssertEqual(viewModel.recentTransactions().count, 1)
        XCTAssertEqual(viewModel.recentTransactions().first?.title, "Zomato")
    }

    func test_delete_removesTransaction() {
        viewModel.add(title: "Zomato", amount: 250, type: .expense, category: "food", date: Date())
        let t = viewModel.recentTransactions()[0]
        viewModel.delete(t)
        XCTAssertEqual(viewModel.recentTransactions().count, 0)
    }

    func test_update_modifiesTransaction() {
        viewModel.add(title: "Old", amount: 100, type: .expense, category: "other", date: Date())
        let t = viewModel.recentTransactions()[0]
        viewModel.update(t, title: "New", amount: 200, type: .income, category: "food", date: Date())
        let updated = viewModel.recentTransactions()[0]
        XCTAssertEqual(updated.title, "New")
        XCTAssertEqual(updated.amount, 200)
        XCTAssertEqual(updated.type, .income)
    }

    func test_summary_calculatesCorrectly() {
        let now = Date()
        viewModel.add(title: "Salary", amount: 50000, type: .income, category: "other", date: now)
        viewModel.add(title: "Rent", amount: 15000, type: .expense, category: "bills", date: now)
        let summary = viewModel.summary(for: now)
        XCTAssertEqual(summary.totalIncome, 50000)
        XCTAssertEqual(summary.totalExpenses, 15000)
        XCTAssertEqual(summary.balance, 35000)
    }

    func test_search_filtersByTitle() {
        let now = Date()
        viewModel.add(title: "Zomato", amount: 250, type: .expense, category: "food", date: now)
        viewModel.add(title: "Uber", amount: 100, type: .expense, category: "transport", date: now)
        let results = viewModel.transactions(for: now, query: "zom")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Zomato")
    }

    func test_categoryBreakdown_percentages() {
        let now = Date()
        viewModel.add(title: "Rent", amount: 10000, type: .expense, category: "bills", date: now)
        viewModel.add(title: "Food", amount: 5000, type: .expense, category: "food", date: now)
        let breakdown = viewModel.categoryBreakdown(for: now)
        XCTAssertEqual(breakdown.count, 2)
        let billsItem = breakdown.first { $0.category == "bills" }!
        XCTAssertEqual(billsItem.percentage, 66.67, accuracy: 0.1)
    }
}
