// PennyWiseSwift/PennyWise/AppState.swift
import Foundation
import SwiftData

@Observable
class AppState {
    var isAuthenticated: Bool = false
    var currentUserID: UUID?
    var currentUser: User?

    init() {
        if let idString = UserDefaults.standard.string(forKey: "activeUserID"),
           let id = UUID(uuidString: idString) {
            self.currentUserID = id
        }
    }

    var hasSavedSession: Bool { currentUserID != nil }

    func setCurrentUser(_ user: User) {
        currentUser = user
        currentUserID = user.id
        UserDefaults.standard.set(user.id.uuidString, forKey: "activeUserID")
        isAuthenticated = true
    }

    func signOut() {
        isAuthenticated = false
        currentUser = nil
        currentUserID = nil
        UserDefaults.standard.removeObject(forKey: "activeUserID")
    }
}
