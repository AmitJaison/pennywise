// PennyWiseSwift/PennyWiseTests/AuthViewModelTests.swift
import XCTest
import SwiftData
@testable import PennyWise

@MainActor
final class AuthViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var appState: AppState!
    var viewModel: AuthViewModel!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: User.self, Transaction.self,
                                       configurations: config)
        context = ModelContext(container)
        appState = AppState()
        viewModel = AuthViewModel(modelContext: context, appState: appState)
        // Clean up any test keychain entries
        KeychainHelper.delete(key: "password-test@example.com")
        KeychainHelper.delete(key: "password-dup@example.com")
        KeychainHelper.delete(key: "session-activeUserID")
    }

    override func tearDown() async throws {
        KeychainHelper.delete(key: "password-test@example.com")
        KeychainHelper.delete(key: "password-dup@example.com")
        KeychainHelper.delete(key: "session-activeUserID")
    }

    func test_signUp_createsUser_andSetsAuthenticated() throws {
        try viewModel.signUp(name: "Amit", email: "test@example.com", password: "secret")
        XCTAssertTrue(appState.isAuthenticated)
        XCTAssertEqual(appState.currentUser?.name, "Amit")
    }

    func test_signIn_withValidCredentials_succeeds() throws {
        try viewModel.signUp(name: "Amit", email: "test@example.com", password: "secret")
        appState.signOut()
        try viewModel.signIn(email: "test@example.com", password: "secret")
        XCTAssertTrue(appState.isAuthenticated)
    }

    func test_signIn_withWrongPassword_throws() throws {
        try viewModel.signUp(name: "Amit", email: "test@example.com", password: "secret")
        appState.signOut()
        XCTAssertThrowsError(try viewModel.signIn(email: "test@example.com", password: "wrong"))
    }

    func test_signUp_duplicateEmail_throws() throws {
        try viewModel.signUp(name: "Amit", email: "dup@example.com", password: "secret")
        appState.signOut()
        XCTAssertThrowsError(try viewModel.signUp(name: "Other", email: "dup@example.com", password: "pass"))
    }

    func test_signOut_clearsState() throws {
        try viewModel.signUp(name: "Amit", email: "test@example.com", password: "secret")
        viewModel.signOut()
        XCTAssertFalse(appState.isAuthenticated)
        XCTAssertNil(appState.currentUser)
    }

    func test_pin_setAndVerify() throws {
        try viewModel.signUp(name: "Amit", email: "test@example.com", password: "secret")
        let userID = appState.currentUser!.id
        viewModel.setPIN("1234", userID: userID)
        XCTAssertTrue(viewModel.hasPIN(userID: userID))
        XCTAssertTrue(viewModel.verifyPIN("1234", userID: userID))
        XCTAssertFalse(viewModel.verifyPIN("0000", userID: userID))
        KeychainHelper.delete(key: "pin-\(userID.uuidString)")
    }

    func test_setCurrentUser_andSignOut_stateTransitions() throws {
        try viewModel.signUp(name: "Amit", email: "test@example.com", password: "secret")
        XCTAssertNotNil(appState.currentUser)
        XCTAssertNotNil(appState.currentUserID)
        XCTAssertTrue(appState.hasSavedSession)
        viewModel.signOut()
        XCTAssertNil(appState.currentUser)
        XCTAssertNil(appState.currentUserID)
        XCTAssertFalse(appState.hasSavedSession)
    }
}
