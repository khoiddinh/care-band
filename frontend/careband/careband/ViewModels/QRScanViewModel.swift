//
//  QRScanViewModel.swift
//  careband
//
//  Created by Khoi Dinh on 4/26/25.
//

import Foundation
import FirebaseAuth
import Observation

@Observable
class QRScanViewModel {
    var patient: Patient?
    var message: String = "Tap scan to begin."
    var isShowingQRScanner = false
    
    func startQRScan() {
        isShowingQRScanner = true
    }
    
    func handleScannedUUID(_ uuid: String) {
        fetchPatientRecord(uuid: uuid)
    }
    
    func fetchPatientRecord(uuid: String) {
        guard let user = Auth.auth().currentUser else {
            self.message = "User not signed in"
            return
        }

        user.getIDToken { token, error in
            guard let token = token else {
                DispatchQueue.main.async {
                    self.message = "Auth token error: \(error?.localizedDescription ?? "Unknown")"
                }
                return
            }

            guard let url = URL(string: "https://\(Config.region)-\(Config.projectID).cloudfunctions.net/getPatientRecord") else {
                DispatchQueue.main.async {
                    self.message = "Invalid backend URL"
                }
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: ["uuid": uuid])

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.message = "Network error: \(error?.localizedDescription ?? "Unknown")"
                    }
                    return
                }

                // 🔥 ADD THIS TO PRINT SERVER RESPONSE
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔥 Raw server response:\n\(jsonString)")
                }

                do {
                    let decoder = JSONDecoder()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    decoder.dateDecodingStrategy = .formatted(formatter)

                    let decoded = try decoder.decode(Patient.self, from: data)
                    DispatchQueue.main.async {
                        self.patient = decoded
                        self.message = "Patient data loaded."
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.message = "Invalid response from server."
                    }
                    print("❌ JSON Decoding failed with error: \(error)")
                }
            }.resume()
        }
    }
}
