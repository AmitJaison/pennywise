// PennyWiseSwift/PennyWise/Views/Auth/SignInView.swift
import SwiftUI

struct SignInView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    let onSignUpTap: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "indianrupeesign.circle.fill")
                        .font(.system(size: 60)).foregroundStyle(.blue)
                    Text("PennyWise").font(.largeTitle.bold())
                    Text("Track your expenses").foregroundStyle(.secondary)
                }
                .padding(.top, 60)

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress).keyboardType(.emailAddress)
                        .autocorrectionDisabled().textInputAutocapitalization(.never)
                        .padding().background(Color(.secondarySystemBackground)).cornerRadius(12)
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding().background(Color(.secondarySystemBackground)).cornerRadius(12)
                }
                .padding(.horizontal)

                if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundStyle(.red).font(.caption).multilineTextAlignment(.center)
                }

                Button(action: signIn) {
                    Group {
                        if isLoading { ProgressView() } else { Text("Sign In") }
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(canSignIn ? Color.blue : Color.gray)
                    .foregroundStyle(.white).cornerRadius(12)
                }
                .disabled(!canSignIn).padding(.horizontal)

                Button("Don't have an account? Sign up", action: onSignUpTap)
                    .font(.footnote).foregroundStyle(.blue)
            }
        }
    }

    private var canSignIn: Bool { !email.isEmpty && !password.isEmpty && !isLoading }

    private func signIn() {
        isLoading = true; errorMessage = ""
        let vm = AuthViewModel(modelContext: modelContext, appState: appState)
        do { try vm.signIn(email: email, password: password) }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
}
