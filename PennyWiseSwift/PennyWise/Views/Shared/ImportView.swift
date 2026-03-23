// PennyWiseSwift/PennyWise/Views/Shared/ImportView.swift
import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.dismiss) private var dismiss
    let transactionViewModel: TransactionViewModel

    @State private var importViewModel = ImportViewModel()
    @State private var showFilePicker = false
    @State private var parsedTransactions: [ParsedTransaction] = []
    @State private var showPasswordAlert = false
    @State private var pdfPassword = ""
    @State private var selectedURL: URL? = nil
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if importViewModel.isImporting {
                    VStack(spacing: 12) {
                        ProgressView(value: importViewModel.progress).padding(.horizontal)
                        Text("Parsing PDF…").foregroundStyle(.secondary)
                    }
                    .padding(.top, 60)
                } else if !parsedTransactions.isEmpty {
                    List(parsedTransactions, id: \.title) { t in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(t.title).font(.subheadline).lineLimit(1)
                                Text(t.category.capitalized).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text((t.type == .expense ? "-" : "+") + CurrencyFormatter.format(t.amount))
                                    .foregroundStyle(t.type == .expense ? .red : .green)
                                    .font(.subheadline.bold())
                                Text(t.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    Button("Import \(parsedTransactions.count) Transactions") {
                        importViewModel.commitImport(parsedTransactions, using: transactionViewModel)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent).padding()
                } else {
                    Spacer()
                    ContentUnavailableView("Import Bank Statement", systemImage: "doc.badge.plus",
                        description: Text("Select a PDF bank statement to import transactions"))
                    if !errorMessage.isEmpty {
                        Text(errorMessage).foregroundStyle(.red).font(.caption)
                            .multilineTextAlignment(.center).padding(.horizontal)
                    }
                    Button("Select PDF") { showFilePicker = true }.buttonStyle(.borderedProminent)
                    Spacer()
                }
            }
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                if !parsedTransactions.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Re-select") { parsedTransactions = []; errorMessage = "" }
                    }
                }
            }
            .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.pdf]) { result in
                switch result {
                case .success(let url):
                    selectedURL = url
                    Task { await processPDF(url: url, password: nil) }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
            .alert("Password Required", isPresented: $showPasswordAlert) {
                SecureField("PDF Password", text: $pdfPassword)
                Button("Cancel", role: .cancel) {}
                Button("Unlock") {
                    if let url = selectedURL {
                        Task { await processPDF(url: url, password: pdfPassword) }
                    }
                }
            } message: { Text("This PDF is password protected.") }
        }
    }

    private func processPDF(url: URL, password: String?) async {
        errorMessage = ""
        do {
            parsedTransactions = try await importViewModel.importPDF(url: url, password: password)
        } catch ImportError.passwordRequired {
            showPasswordAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
