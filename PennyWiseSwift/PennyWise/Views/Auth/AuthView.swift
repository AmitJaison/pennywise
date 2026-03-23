// PennyWiseSwift/PennyWise/Views/Auth/AuthView.swift
import SwiftUI

struct AuthView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var screen: Screen = .signIn

    enum Screen { case signIn, signUp, pin }

    var body: some View {
        Group {
            switch screen {
            case .signIn:
                SignInView(onSignUpTap: { screen = .signUp })
            case .signUp:
                SignUpView(onSignInTap: { screen = .signIn })
            case .pin:
                if let userID = appState.currentUserID {
                    PINEntryView(
                        userID: userID,
                        onSuccess: {},
                        onFallback: { screen = .signIn }
                    )
                } else {
                    SignInView(onSignUpTap: { screen = .signUp })
                }
            }
        }
        .task { await handleColdLaunch() }
    }

    private func handleColdLaunch() async {
        guard appState.hasSavedSession, let userID = appState.currentUserID else { return }
        let vm = AuthViewModel(modelContext: modelContext, appState: appState)
        let restored = await vm.restoreSession()
        if !restored {
            screen = vm.hasPIN(userID: userID) ? .pin : .signIn
        }
    }
}
