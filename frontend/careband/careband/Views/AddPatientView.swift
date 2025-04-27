//
//  AddPatientView.swift
//  careband
//
//  Created by Khoi Dinh on 4/25/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFunctions


struct AddPatientView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var dob = Date()
    @State private var ssn = ""
    @State private var allergies: [String] = []
    @State private var newAllergyEntry = "" // Temporary input field for adding new allergy
    @State private var history = ""
    @State private var message: String?
    @State private var showSuccess = false
    @State private var showQRCodeSheet = false
    @State private var generatedUUID: String?


    var body: some View {
        Form {
            Section(header: Text("Patient Info")) {
                TextField("Name", text: $name)

                HStack {
                    Text("DOB")
                    Spacer()
                    DatePicker("", selection: $dob, displayedComponents: .date)
                        .labelsHidden()
                }

                TextField("SSN", text: $ssn)
 
                VStack(alignment: .leading) {
                    Text("Add Allergy")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    TextField("Allergy", text: $newAllergyEntry, onCommit: {
                        let trimmed = newAllergyEntry.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty && !allergies.contains(trimmed) {
                            allergies.append(trimmed)
                        }
                        newAllergyEntry = ""
                    })
                    .textFieldStyle(.roundedBorder)

                    if !allergies.isEmpty {
                        ForEach(allergies, id: \.self) { allergy in
                            Text("- \(allergy)")
                                .font(.caption)
                        }
                    }
                }

                VStack(alignment: .leading) {
                    Text("History")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    TextEditor(text: $history)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }

            Button("Add Patient") {
                addPatient()
            }
            .alert("Patient Added", isPresented: $showSuccess) {
                Button("Go Home") {
                    dismiss()
                }
            }

            if let message = message {
                Text(message).foregroundColor(.blue)
            }
        }
        .navigationTitle("Add Patient")
        .sheet(isPresented: $showQRCodeSheet) {
            if let uuid = generatedUUID {
                QRCodeSheet(uuid: uuid)
            }
        }
    }

    func addPatient() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dobString = formatter.string(from: dob)

        guard let url = URL(string: "https://us-central1-care-band-2bab5.cloudfunctions.net/addOrUpdatePatient") else {
            self.message = "Invalid backend URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "name": name,
            "dob": dobString,
            "ssn": ssn,
            "allergies": allergies.joined(separator: "; "), // Join allergies
            "history": history
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    self.message = "Network error"
                }
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let uuid = (json["uuid"] as? String) ?? (json["newUUID"] as? String) {
                DispatchQueue.main.async {
                    self.generatedUUID = uuid
                    self.showQRCodeSheet = true

                    // reset form
                    self.message = nil
                    self.name = ""
                    self.dob = Date()
                    self.ssn = ""
                    self.allergies = []
                    self.newAllergyEntry = ""
                    self.history = ""
                }
            } else {
                let serverResponse = String(data: data, encoding: .utf8) ?? "Unknown server response"
                DispatchQueue.main.async {
                    self.message = "Server error: \(serverResponse)"
                }
            }
        }.resume()
    }
}
