// PennyWiseSwift/PennyWise/Models/User.swift
import Foundation
import SwiftData

@Model
class User {
    @Attribute(.unique) var id: UUID
    var name: String
    @Attribute(.unique) var email: String  // unique — prevents Keychain key collision
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var transactions: [Transaction]

    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.createdAt = Date()
        self.transactions = []
    }
}
