// PennyWiseSwift/PennyWise/Views/Auth/SignUpView.swift
import SwiftUI

struct SignUpView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    let onSignInTap: () -> Void

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var passwordsMatch: Bool { password == confirmPassword }
    var canSubmit: Bool { !name.isEmpty && !email.isEmpty && !password.isEmpty && passwordsMatch && !isLoading }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "indianrupeesign.circle.fill")
                        .font(.system(size: 60)).foregroundStyle(.blue)
                    Text("Create Account").font(.largeTitle.bold())
                }
                .padding(.top, 60)

                VStack(spacing: 16) {
                    TextField("Full Name", text: $name).textContentType(.name)
                        .padding().background(Color(.secondarySystemBackground)).cornerRadius(12)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress).keyboardType(.emailAddress)
                        .autocorrectionDisabled().textInputAutocapitalization(.never)
                        .padding().background(Color(.secondarySystemBackground)).cornerRadius(12)
                    SecureField("Password", text: $password).textContentType(.newPassword)
                        .padding().background(Color(.secondarySystemBackground)).cornerRadius(12)
                    SecureField("Confirm Password", text: $confirmPassword).textContentType(.newPassword)
                        .padding().background(Color(.secondarySystemBackground)).cornerRadius(12)
                    if !password.isEmpty && !confirmPassword.isEmpty && !passwordsMatch {
                        Text("Passwords do not match").foregroundStyle(.red).font(.caption)
                    }
                }
                .padding(.horizontal)

                if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundStyle(.red).font(.caption).multilineTextAlignment(.center)
                }

                Button(action: signUp) {
                    Group {
                        if isLoading { ProgressView() } else { Text("Create Account") }
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(canSubmit ? Color.blue : Color.gray)
                    .foregroundStyle(.white).cornerRadius(12)
                }
                .disabled(!canSubmit).padding(.horizontal)

                Button("Already have an account? Sign in", action: onSignInTap)
                    .font(.footnote).foregroundStyle(.blue)
            }
        }
    }

    private func signUp() {
        isLoading = true; errorMessage = ""
        let vm = AuthViewModel(modelContext: modelContext, appState: appState)
        do { try vm.signUp(name: name, email: email, password: password) }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
}
