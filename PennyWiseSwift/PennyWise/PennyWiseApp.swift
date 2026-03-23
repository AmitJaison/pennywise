// PennyWiseSwift/PennyWise/PennyWiseApp.swift
import SwiftUI
import SwiftData

@main
struct PennyWiseApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .modelContainer(for: [User.self, Transaction.self])
    }
}

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if appState.isAuthenticated {
            MainTabView()
        } else {
            AuthView()
        }
    }
}
