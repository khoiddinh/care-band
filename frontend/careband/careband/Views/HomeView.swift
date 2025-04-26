//
//  HomeView.swift
//  careband
//
//  Created by Khoi Dinh on 4/25/25.
//
import SwiftUI

struct HomeView: View {
    @Environment(AuthViewModel.self) var authViewModel
    
    var body: some View {
        List {
            NavigationLink("Scan Bracelet", destination: ScanView().environment(authViewModel))
            NavigationLink("Add Patient Record", destination: AddPatientView().environment(authViewModel))
            NavigationLink("Update Patient Record", destination: SelectPatientView().environment(authViewModel))
        }
        .navigationTitle("CareBand")
    }
}
