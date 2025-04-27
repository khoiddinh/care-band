//
//  LoginView.swift
//  careband
//
//  Created by Khoi Dinh on 4/25/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var email: String = ""
    @State private var password: String = ""

    @State private var animateContent = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(UIColor.systemGroupedBackground), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 16) {
                    Image("carebandlogo_no_text")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 90)
                        .opacity(animateContent ? 1 : 0)
                        .scaleEffect(animateContent ? 1.0 : 0.8)
                        .animation(.interpolatingSpring(stiffness: 100, damping: 12), value: animateContent)
                        .padding(.bottom, 10)

                    Text("CareBand")
                        .font(.system(size: 36, weight: .bold))
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateContent)

                    Text("Hospital Login")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: animateContent)

                    VStack(spacing: 12) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)

                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.top, 10)
                    .opacity(animateContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.6), value: animateContent)

                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)

                Button(action: {
                    triggerHaptic()
                    authViewModel.signIn(email: email, password: password)
                }) {
                    Text("Login")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 20)
                .padding(.horizontal)
                .opacity(animateContent ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.8), value: animateContent)

                Spacer()
            }
            .onAppear {
                animateContent = true
            }
        }
    }

    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}
