// PennyWiseSwift/PennyWise/ViewModels/ImportViewModel.swift
// Full ImportViewModel is added in Task 14. This file provides ParsedTransaction
// so PDFParser and its tests compile.
import Foundation

struct ParsedTransaction {
    let title: String
    let amount: Double
    let type: TransactionType
    let date: Date
    let category: String
}
