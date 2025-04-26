//
//  SelectPatientView.swift
//  careband
//
//  Created by Khoi Dinh on 4/25/25.
//
import SwiftUI
import FirebaseAuth


struct SelectPatientView: View {
    @State private var ssn = ""
    @State private var dob: Date? = nil
    @State private var uuid = ""
    @State private var message: String?
    @State private var selectedPatient: Patient?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Search Patient")) {
                    TextField("SSN", text: $ssn)
                        .keyboardType(.numberPad)
                        .textContentType(.none)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    VStack(alignment: .leading) {
                        if dob != nil {
                            DatePicker("DOB", selection: Binding(
                                get: { dob ?? Date() },
                                set: { dob = $0 }
                            ), displayedComponents: .date)
                            .datePickerStyle(.compact)

                            Button("Clear DOB") {
                                dob = nil
                            }
                            .foregroundColor(.red)
                            .font(.caption)
                        } else {
                            Button("Select DOB") {
                                dob = Date()
                            }
                            .foregroundColor(.blue)
                        }
                    }

                    TextField("UUID", text: $uuid)
                        .textContentType(.none)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                Button("Find Patient") {
                    findPatient()
                }

                if let message = message {
                    Text(message).foregroundColor(.red)
                }

                if selectedPatient != nil {
                    Text("Patient ready. Tap below.")
                        .foregroundColor(.green)
                }
            }
            .navigationTitle("Select Patient")
            .navigationDestination(item: $selectedPatient) { patient in
                UpdatePatientView(existingPatient: patient)
            }
        }
    }

    func findPatient() {
        guard let url = URL(string: "https://\(Config.region)-\(Config.projectID).cloudfunctions.net/findPatient") else {
            self.message = "Invalid backend URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [:]
        if !uuid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            body["uuid"] = uuid.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if !ssn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            body["ssn"] = ssn.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if let dob = dob {
            body["dob"] = formatter.string(from: dob)
        } else {
            body["dob"] = ""
        }


        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    self.message = "Network error: \(error?.localizedDescription ?? "Unknown error")"
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)

                let decoded = try decoder.decode(Patient.self, from: data)

                DispatchQueue.main.async {
                    self.selectedPatient = decoded
                    self.message = nil
                }
                return
            } catch {
                if let serverResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let serverError = serverResponse["error"] as? String {
                    DispatchQueue.main.async {
                        self.message = "Server error: \(serverError)"
                        print("Server error: \(serverError)")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.message = "Unknown server error."
                        print("Unknown server response: \(String(data: data, encoding: .utf8) ?? "No data")")
                    }
                }
            }
        }.resume()
    }
}
