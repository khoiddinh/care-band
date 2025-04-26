//
//  ScanView.swift
//  careband
//
//  Created by Khoi Dinh on 4/25/25.
//
import SwiftUI

struct ScanView: View {
    @State var viewModel = ScanViewModel()
    
    @Environment(AuthViewModel.self) var authViewModel

    var body: some View {
        VStack(spacing: 20) {
            if let patient = viewModel.patient {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Name: \(patient.name)")
                    Text("DOB: \(patient.dob)")
                    Text("SSN: \(patient.ssn)")
                    Text("Allergies: \(patient.allergies)")
                    Text("History: \(patient.history)")
                }
                .padding()
            } else {
                Text(viewModel.message)
                    .foregroundColor(.gray)
            }

            Button("Scan Bracelet") {
                viewModel.startScanning()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())

        }
        .padding()
    }
}
