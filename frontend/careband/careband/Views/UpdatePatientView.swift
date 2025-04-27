//
//  UpdatePatientView.swift
//  careband
//
//  Created by Khoi Dinh on 4/25/25.
//
import SwiftUI
import FirebaseAuth

struct UpdatePatientView: View {
    @Environment(\.dismiss) private var dismiss
    let existingPatient: Patient

    @State private var name: String
    @State private var dob: Date
    @State private var ssn: String
    @State private var allergies: [String]
    @State private var history: String
    @State private var message: String?
    @State private var showSuccess = false
    @State private var showNewUUIDWarning = false
    @State private var newHistoryEntry: String = ""
    @State private var newAllergyEntry: String = ""

    init(existingPatient: Patient) {
        self.existingPatient = existingPatient
        _name = State(initialValue: existingPatient.name)
        _dob = State(initialValue: existingPatient.dob)
        _ssn = State(initialValue: existingPatient.ssn)
        _allergies = State(initialValue: existingPatient.allergies)
        _history = State(initialValue: existingPatient.history)
    }

    var body: some View {
        Form {
            Section(header: Text("Edit Patient Info")) {
                VStack(alignment: .leading) {
                    Text("Name")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading) {
                    Text("DOB")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    DatePicker("", selection: $dob, displayedComponents: .date)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading) {
                    Text("SSN")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    TextField("SSN", text: $ssn)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading) {
                    Text("Allergies")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    TextField("Add Allergy", text: $newAllergyEntry, onCommit: {
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

                VStack(alignment: .leading, spacing: 8) {
                    Text("Add New History Entry")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    TextEditor(text: $newHistoryEntry)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Existing History")
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

            Button("Update Patient") {
                updatePatient()
            }
            .alert("Patient Updated", isPresented: $showSuccess) {
                Button("Go Home") {
                    dismiss()
                }
            }

            Button("Generate New UUID (New Bracelet)") {
                showNewUUIDWarning = true
            }
            .foregroundColor(.red)
            .alert("Warning", isPresented: $showNewUUIDWarning) {
                Button("Cancel", role: .cancel) { }
                Button("Proceed") {
                    generateNewUUID()
                }
            } message: {
                Text("Generating a new UUID will require the patient to be issued a new bracelet. Proceed?")
            }

            if let message = message {
                Text(message).foregroundColor(.blue)
            }
        }
        .navigationTitle("Update Patient")
    }

    // 🧠 Parses old history nicely
    var parsedHistoryEntries: [HistoryEntry] {
        let lines = history.components(separatedBy: "\n")
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

    func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    func updatePatient() {
        guard let user = Auth.auth().currentUser else {
            self.message = "User not signed in"
            return
        }

        user.getIDToken { token, error in
            guard let token = token else {
                self.message = "Auth token error"
                return
            }

            guard let url = URL(string: "https://\(Config.region)-\(Config.projectID).cloudfunctions.net/addOrUpdatePatient") else {
                self.message = "Invalid backend URL"
                return
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dobString = formatter.string(from: dob)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // ✏️ ONLY send the new history text (not the full old history)
            let trimmedHistory = newHistoryEntry.trimmingCharacters(in: .whitespacesAndNewlines)

            let body: [String: Any] = [
                "uuid": existingPatient.uuid,
                "name": name,
                "dob": dobString,
                "ssn": ssn,
                "allergies": allergies.joined(separator: "; "),
                "history": trimmedHistory // only new update
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard data != nil else {
                    DispatchQueue.main.async {
                        self.message = "Update failed."
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.showSuccess = true
                }
            }.resume()
        }
    }

    func generateNewUUID() {
        guard let user = Auth.auth().currentUser else {
            self.message = "User not signed in"
            return
        }

        user.getIDToken { token, error in
            guard let token = token else {
                self.message = "Auth token error"
                return
            }

            guard let url = URL(string: "https://\(Config.region)-\(Config.projectID).cloudfunctions.net/addOrUpdatePatient") else {
                self.message = "Invalid backend URL"
                return
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dobString = formatter.string(from: dob)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = [
                "name": name,
                "dob": dobString,
                "ssn": ssn,
                "allergies": allergies.joined(separator: "; "),
                "history": history
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.message = "Failed to generate new UUID."
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.message = "New UUID created successfully."
                    self.showSuccess = true
                }
            }.resume()
        }
    }

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
