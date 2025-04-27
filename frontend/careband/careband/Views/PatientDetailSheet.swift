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
            Form {
                Section(header: Text("Basic Information")) {
                    patientRow(label: "Name", value: patient.name)
                    patientRow(label: "Date of Birth", value: formattedDate(patient.dob))
                    patientRow(label: "SSN", value: patient.ssn)
                }

                Section(header: Text("Medical Information")) {
                    patientRow(label: "Allergies", value: patient.allergies.isEmpty ? "None" : patient.allergies.joined(separator: ", "))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("History")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        ScrollView {
                            Text(patient.history.isEmpty ? "No history available." : patient.history)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                        }
                        .frame(minHeight: 100) // enough room for history text
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Patient Info")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    func patientRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
