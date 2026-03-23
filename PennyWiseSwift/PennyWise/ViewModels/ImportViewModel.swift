// PennyWiseSwift/PennyWise/ViewModels/ImportViewModel.swift
import Foundation
import PDFKit

// Full ImportViewModel is added in Task 14. This file also defines ParsedTransaction
// so PDFParser can reference it.

struct ParsedTransaction {
    let title: String
    let amount: Double
    let type: TransactionType
    let date: Date
    let category: String
}

enum ImportError: LocalizedError {
    case passwordRequired
    case fileAccessDenied
    case parsingFailed

    var errorDescription: String? {
        switch self {
        case .passwordRequired:  return "This PDF is password protected. Enter the password to continue."
        case .fileAccessDenied:  return "Could not access the selected file."
        case .parsingFailed:     return "Could not extract transactions from this PDF."
        }
    }
}

@Observable
@MainActor
class ImportViewModel {
    var progress: Double = 0.0
    var isImporting: Bool = false

    func importPDF(url: URL, password: String?) async throws -> [ParsedTransaction] {
        isImporting = true
        progress = 0.1
        defer { isImporting = false; progress = 0 }

        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.fileAccessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }

        guard let document = PDFDocument(url: url) else {
            throw ImportError.parsingFailed
        }

        progress = 0.3

        if document.isLocked {
            guard let pwd = password, document.unlock(withPassword: pwd) else {
                throw ImportError.passwordRequired
            }
        }

        progress = 0.6
        let results = PDFParser.parse(document: document)
        progress = 1.0

        guard !results.isEmpty else { throw ImportError.parsingFailed }
        return results
    }

    func commitImport(_ transactions: [ParsedTransaction], using viewModel: TransactionViewModel) {
        for t in transactions {
            viewModel.add(title: t.title, amount: t.amount, type: t.type,
                          category: t.category, date: t.date)
        }
    }
}
