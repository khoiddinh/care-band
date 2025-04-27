//
//  HomeView.swift
//  careband
//
//  Created by Khoi Dinh on 4/25/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(AuthViewModel.self) var authViewModel
    @State private var showHomeContent = false
    @State private var animateIcon = false
    @State private var animateText = false
    @State private var animateButton = false


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
        VStack(spacing: 30) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "heart.text.square.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
                    .scaleEffect(animateIcon ? 1.1 : 0.7) // pulse in once
                    .opacity(animateIcon ? 1 : 0)
                    .animation(.easeOut(duration: 0.8), value: animateIcon)
                    .padding(.bottom, 10)

                Text("Welcome to")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.3), value: animateText)

                Text("CareBand")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.primary)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.5), value: animateText)
            }
            .multilineTextAlignment(.center)
            .padding()

            Spacer()

            if animateButton {
                Button(action: {
                    showHomeContent = true
                }) {
                    Text("Enter")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .shadow(radius: 5)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateButton)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            animateIcon = true
            animateText = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                animateButton = true
            }
        }
    }



    var mainHomeContent: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome back,")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(authViewModel.user?.displayName ?? "Khoi")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                }
                .padding(.vertical)
            }
            .listRowBackground(Color.clear)

            Section(header: Text("Actions").font(.headline)) {
                NavigationLink(destination: ScanView().environment(authViewModel)) {
                    Label("Scan Bracelet", systemImage: "wave.3.forward.circle")
                }
                NavigationLink(destination: AddPatientView().environment(authViewModel)) {
                    Label("Add Patient Record", systemImage: "plus.circle")
                }
                NavigationLink(destination: SelectPatientView()) {
                    Label("Update Patient Record", systemImage: "pencil.circle")
                }
                NavigationLink(destination: SelectPatientForViewingView()) {
                    Label("View Patient Information", systemImage: "doc.text.magnifyingglass")
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        authViewModel.signOut()
                    } label: {
                        Label("Logout", systemImage: "arrow.backward.circle")
                    }
                } label: {
                    HStack {
                        Image(systemName: "person.crop.circle")
                        Text(authViewModel.user?.displayName ?? "Profile")
                    }
                    .font(.subheadline)
                    .foregroundColor(.primary)
                }
            }
        }
    }
}
