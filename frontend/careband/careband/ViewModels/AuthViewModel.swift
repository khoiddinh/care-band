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

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            Task { @MainActor in
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
                    self.isAuthenticated = true
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            Task { @MainActor in
                self.isAuthenticated = false
            }
        } catch {
            Task { @MainActor in
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
