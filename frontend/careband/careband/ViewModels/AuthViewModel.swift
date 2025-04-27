//
//  AuthViewModel.swift
//  careband
//
//  Created by Khoi Dinh on 4/25/25.
//
import Observation
import FirebaseAuth

@Observable
class AuthViewModel {
    var isAuthenticated: Bool = false
    var errorMessage: String?
    var user: User?

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            Task { @MainActor in
                self.user = user // ✅ Track the user object
                self.isAuthenticated = user != nil
            }
        }
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            Task { @MainActor in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.errorMessage = nil
                    self.user = result?.user // ✅ Save the user on successful login
                    self.isAuthenticated = true
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            Task { @MainActor in
                self.user = nil
                self.isAuthenticated = false
            }
        } catch {
            Task { @MainActor in
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
