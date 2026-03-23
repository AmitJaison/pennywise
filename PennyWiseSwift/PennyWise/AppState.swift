// PennyWiseSwift/PennyWise/AppState.swift
import Foundation
import SwiftData

@Observable
@MainActor
class AppState {
    var isAuthenticated: Bool = false
    var currentUserID: UUID?
    var currentUser: User?

    private static let sessionKey = "session-activeUserID"

    init() {
        if let data = KeychainHelper.load(key: Self.sessionKey),
           let idString = String(data: data, encoding: .utf8),
           let id = UUID(uuidString: idString) {
            self.currentUserID = id
        }
    }

    var hasSavedSession: Bool { currentUserID != nil }

    func setCurrentUser(_ user: User) {
        currentUser = user
        currentUserID = user.id
        if let data = user.id.uuidString.data(using: .utf8) {
            KeychainHelper.store(value: data, key: Self.sessionKey)
        }
        isAuthenticated = true
    }

    func signOut() {
        isAuthenticated = false
        currentUser = nil
        currentUserID = nil
        KeychainHelper.delete(key: Self.sessionKey)
    }
}
