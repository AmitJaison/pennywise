// PennyWiseSwift/PennyWise/Views/Shared/PINEntryView.swift
import SwiftUI
import SwiftData

struct PINEntryView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    let userID: UUID
    let onSuccess: () -> Void
    let onFallback: () -> Void

    @State private var pin = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            Text("Enter PIN")
                .font(.title2.bold())
            SecureField("PIN", text: $pin)
                .keyboardType(.numberPad)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal, 60)
            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundStyle(.red).font(.caption)
            }
            Button("Verify PIN") { verifyPIN() }
                .disabled(pin.count < 4)
                .buttonStyle(.borderedProminent)
            Button("Use Password Instead", action: onFallback)
                .font(.footnote).foregroundStyle(.secondary)
            Spacer()
        }
    }

    private func verifyPIN() {
        let vm = AuthViewModel(modelContext: modelContext, appState: appState)
        if vm.verifyPIN(pin, userID: userID) {
            let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == userID })
            if let user = (try? modelContext.fetch(descriptor))?.first {
                appState.setCurrentUser(user)
                onSuccess()
            }
        } else {
            errorMessage = "Incorrect PIN"
            pin = ""
        }
    }
}
