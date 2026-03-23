// PennyWiseSwift/PennyWise/Models/TransactionType.swift
import Foundation

// SwiftData persists via rawValue — Codable is for JSON export only
enum TransactionType: String, Codable, CaseIterable {
    case expense
    case income
}
