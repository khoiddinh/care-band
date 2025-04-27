//
//  ContentView.swift
//  careband
//
//  Created by Khoi Dinh on 4/25/25.
//

import SwiftUI

struct ContentView: View {
    @State var authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            if authViewModel.isAuthenticated {
                HomeView()
                    .environment(authViewModel)
            } else {
                LoginView()
                    .environment(authViewModel)
            }
        }
    }
}
#Preview {
    ContentView()
}
