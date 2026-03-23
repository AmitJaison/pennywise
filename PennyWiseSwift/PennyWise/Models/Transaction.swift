// PennyWiseSwift/PennyWise/Models/Transaction.swift
import Foundation
import SwiftData

@Model
class Transaction {
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Double      // always positive; type determines income vs expense
    var type: TransactionType
    var category: String    // one of 13 canonical categories
    var date: Date
    var userId: UUID        // denormalized for #Predicate compatibility
    // WARNING: do not reassign `user` without also updating `userId` — they must stay in sync
    var user: User

    init(title: String, amount: Double, type: TransactionType,
         category: String, date: Date, user: User) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.type = type
        self.category = category
        self.date = date
        self.userId = user.id
        self.user = user
        assert(amount > 0, "Transaction amount must be positive")
    }
}
