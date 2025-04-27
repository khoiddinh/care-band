//
//  HomeView.swift
//  careband
//
//  Created by Khoi Dinh on 4/25/25.
//


import SwiftUI
import UIKit


struct HomeView: View {
    @Environment(AuthViewModel.self) var authViewModel
    @State private var showHomeContent = false
    @State private var animateText = false
    @State private var animateLogo = false
    @State private var animateButton = false
    @State private var isLoading = false
    @State private var animateContent = false



    var body: some View {
        Group {
            if showHomeContent {
                mainHomeContent
            } else {
                welcomeScreen
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showHomeContent)
        .navigationBarBackButtonHidden(true)
    }

    var welcomeScreen: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(UIColor.systemGroupedBackground), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                VStack(spacing: 12) {
                    Text("Welcome to")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .opacity(animateText ? 1 : 0)
                        .offset(y: animateText ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateText)

                    Image("carebandlogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 90)
                        .opacity(animateLogo ? 1 : 0)
                        .scaleEffect(animateLogo ? 1.0 : 0.8)
                        .animation(.interpolatingSpring(stiffness: 100, damping: 10).delay(0.5), value: animateLogo)
                        .padding(.top, 8)
                }
                .multilineTextAlignment(.center)

                Spacer()

                if animateButton {
                    Button(action: {
                        triggerHaptic()
                        isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            showHomeContent = true
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Continue")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .shadow(radius: 5)
                    .scaleEffect(animateButton ? 1.0 : 0.95)
                    .opacity(animateButton ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.75), value: animateButton)
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            animateText = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                animateLogo = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                animateButton = true
            }
        }

    }



    var mainHomeContent: some View {
        VStack(spacing: 30) {
            customHeader

            VStack(spacing: 8) {
                Text("Welcome back,")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)

                Text(authViewModel.user?.displayName ?? "Khoi")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
            }
            .multilineTextAlignment(.center)
            .padding(.top, 5)
            .animation(.easeOut(duration: 0.8), value: animateContent)

            VStack(spacing: 20) {
                NavigationLink(destination: ScanView()) {
                    bigActionButton(label: "Scan Bracelet or QR Code", systemImage: "wave.3.forward.circle.fill", color: .blue)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    triggerHaptic()
                })

                NavigationLink(destination: AddPatientView()) {
                    bigActionButton(label: "Create New Patient Bracelet", systemImage: "plus.circle.fill", color: .gray)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    triggerHaptic()
                })
            }

            .padding(.horizontal)
            .padding(.top, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            animateContent = true
        }
    }

    var customHeader: some View {
        HStack {
            Image("carebandlogo")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 60)
                .opacity(animateLogo ? 1 : 0)
                .scaleEffect(animateLogo ? 1.0 : 0.8)
                .animation(.interpolatingSpring(stiffness: 100, damping: 10).delay(0.5), value: animateLogo)
                .padding(.top, 8)


            Spacer()

            Menu {
                Button(role: .destructive) {
                    authViewModel.signOut()
                } label: {
                    Label("Logout", systemImage: "arrow.backward.circle")
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "person.crop.circle")
                    Text(authViewModel.user?.displayName ?? "Profile")
                }
                .font(.subheadline)
                .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    func bigActionButton(label: String, systemImage: String, color: Color) -> some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title2)
            Text(label)
                .font(.headline)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, minHeight: 60)
        .background(color)
        .cornerRadius(14)
        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 5)
    }
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

}
