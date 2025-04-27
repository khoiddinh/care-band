//
//  PatientActionView.swift
//  careband
//
//  Created by Khoi Dinh on 4/27/25.
//


import SwiftUI

struct PatientActionView: View {
    let patient: Patient

    var body: some View {
        VStack(spacing: 30) {
            Text("Patient Found!")
                .font(.title.bold())
                .padding(.top, 40)

            Spacer()

            NavigationLink(destination: ViewPatientView(existingPatient: patient)) {
                Text("View Patient Info")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }

            NavigationLink(destination: UpdatePatientView(existingPatient: patient)) {
                Text("Update Patient Info")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .navigationTitle("Patient Actions")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
    }
}
