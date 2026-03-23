// PennyWiseSwift/PennyWise/ViewModels/AuthViewModel.swift
import Foundation
import SwiftData
import CryptoKit
import LocalAuthentication

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyExists
    case userNotFound

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid email or password"
        case .emailAlreadyExists: return "An account with this email already exists"
        case .userNotFound: return "Account not found"
        }
    }
}

@Observable
@MainActor
class AuthViewModel {
    private let modelContext: ModelContext
    private let appState: AppState

    init(modelContext: ModelContext, appState: AppState) {
        self.modelContext = modelContext
        self.appState = appState
    }

    // MARK: - Auth

    func signIn(email: String, password: String) throws {
        let lowerEmail = email.lowercased()
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.email == lowerEmail })
        guard let user = try modelContext.fetch(descriptor).first else {
            throw AuthError.invalidCredentials
        }
        guard let stored = KeychainHelper.load(key: "password-\(lowerEmail)") else {
            throw AuthError.invalidCredentials
        }
        let input = Data(SHA256.hash(data: Data(password.utf8)))
        guard stored == input else { throw AuthError.invalidCredentials }
        appState.setCurrentUser(user)
    }

    func signUp(name: String, email: String, password: String) throws {
        let lowerEmail = email.lowercased()
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.email == lowerEmail })
        if try modelContext.fetch(descriptor).first != nil {
            throw AuthError.emailAlreadyExists
        }
        let user = User(name: name, email: lowerEmail)
        modelContext.insert(user)
        let hash = Data(SHA256.hash(data: Data(password.utf8)))
        KeychainHelper.store(value: hash, key: "password-\(lowerEmail)")
        try modelContext.save()
        appState.setCurrentUser(user)
    }

    func signOut() {
        appState.signOut()
    }

    // MARK: - Biometrics

    @MainActor
    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                        error: &error) else { return false }
        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Sign in to PennyWise"
            )
        } catch {
            return false
        }
    }

    // MARK: - PIN

    func setPIN(_ pin: String, userID: UUID) {
        let hash = Data(SHA256.hash(data: Data(pin.utf8)))
        KeychainHelper.store(value: hash, key: "pin-\(userID.uuidString)")
    }

    func verifyPIN(_ pin: String, userID: UUID) -> Bool {
        guard let stored = KeychainHelper.load(key: "pin-\(userID.uuidString)") else { return false }
        let hash = Data(SHA256.hash(data: Data(pin.utf8)))
        return stored == hash
    }

    func hasPIN(userID: UUID) -> Bool {
        KeychainHelper.load(key: "pin-\(userID.uuidString)") != nil
    }

    // MARK: - Session Restore

    /// Call on cold launch when AppState.hasSavedSession == true.
    /// Returns true if biometrics succeeded and session was restored.
    /// Caller (AuthView) is responsible for showing PIN/SignIn if this returns false.
    func restoreSession() async -> Bool {
        guard let userID = appState.currentUserID else { return false }
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == userID })
        guard let user = (try? modelContext.fetch(descriptor))?.first else {
            // Stale session — user no longer in database (e.g. after data wipe)
            appState.signOut()
            return false
        }
        if await authenticateWithBiometrics() {
            appState.setCurrentUser(user)
            return true
        }
        return false
    }
}
