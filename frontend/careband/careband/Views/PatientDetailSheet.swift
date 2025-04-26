//
//  PatientDetailSheet.swift
//  careband
//
//  Created by Khoi Dinh on 4/26/25.
//


import SwiftUI

struct PatientDetailSheet: View {
    let patient: Patient

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                Group {
                    Text("Name: \(patient.name)")
                    Text("DOB: \(formattedDate(patient.dob))")
                    Text("SSN: \(patient.ssn)")
                    Text("Allergies: \(patient.allergies.joined(separator: ", "))")
                    Text("History:")
                    ScrollView {
                        Text(patient.history)
                            .padding(.top, 2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .font(.body)

                Spacer()
            }
            .padding()
            .navigationTitle("Patient Info")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
