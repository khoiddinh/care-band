//
//  ViewPatientView.swift
//  careband
//
//  Created by Khoi Dinh on 4/27/25.
//


import SwiftUI

struct ViewPatientView: View {
    let existingPatient: Patient

    var body: some View {
        Form {
            Section(header: Text("Patient Info")) {
                patientRow(label: "Name", value: existingPatient.name)
                patientRow(label: "Date of Birth", value: formattedDate(existingPatient.dob))
                patientRow(label: "SSN", value: existingPatient.ssn)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Allergies")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    if existingPatient.allergies.isEmpty {
                        Text("None")
                            .font(.body)
                    } else {
                        ForEach(existingPatient.allergies, id: \.self) { allergy in
                            Text("- \(allergy)")
                                .font(.body)
                        }
                    }
                }
                .padding(.top, 4)

                VStack(alignment: .leading, spacing: 8) {
                    Text("History")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    if parsedHistoryEntries.isEmpty {
                        Text("No history available.")
                            .font(.body)
                    } else {
                        ForEach(parsedHistoryEntries, id: \.self) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.date)
                                    .font(.caption)
                                    .foregroundColor(.blue)

                                Text(entry.note)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                Divider()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .navigationTitle("Patient Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func patientRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // ✅ Parse the history string into structured entries
    var parsedHistoryEntries: [HistoryEntry] {
        let lines = existingPatient.history.components(separatedBy: "\n")
        return lines.compactMap { line in
            parseHistoryLine(line)
        }
    }

    struct HistoryEntry: Hashable {
        let date: String
        let note: String
    }

    func parseHistoryLine(_ line: String) -> HistoryEntry? {
        guard let start = line.firstIndex(of: "["), let end = line.firstIndex(of: "]") else {
            return nil
        }

        let dateRange = line.index(after: start)..<end
        let date = String(line[dateRange])

        let noteStart = line.index(after: end)
        let note = line[noteStart...].trimmingCharacters(in: .whitespaces)

        return HistoryEntry(date: date, note: note)
    }
}
