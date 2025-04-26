//
//  ScanViewModel.swift
//  careband
//
//  Created by Khoi Dinh on 4/25/25.
//
import Foundation
import FirebaseAuth
import CoreNFC
import Observation

@Observable
class ScanViewModel: NSObject, NFCNDEFReaderSessionDelegate {
    var patient: Patient?
    var message: String = "Tap scan to begin."
    private var session: NFCNDEFReaderSession?

    func startScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            self.message = "NFC not supported on this device"
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near the bracelet."
        session?.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.message = "Scan failed: \(error.localizedDescription)"
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let firstMessage = messages.first else {
            DispatchQueue.main.async {
                self.message = "No NDEF messages found."
            }
            return
        }
        
        for (i, record) in firstMessage.records.enumerated() {
            print("Record \(i):")
            print("- Type Name Format: \(record.typeNameFormat.rawValue)")
            print("- Type: \(String(data: record.type, encoding: .utf8) ?? "Unknown Type")")
            print("- Identifier: \(String(data: record.identifier, encoding: .utf8) ?? "Unknown Identifier")")
            print("- Payload (raw bytes): \(record.payload as NSData)")
            print("- Payload (utf8): \(String(data: record.payload.dropFirst(), encoding: .utf8) ?? "Unreadable payload")")
            print("-----------------------------")
        }
        
        if let record = firstMessage.records.first,
           let uuid = String(data: record.payload.dropFirst(), encoding: .utf8) {
            //fetchPatientRecord(uuid: uuid) //TODO: make this go the update patient view
        } else {
            DispatchQueue.main.async {
                self.message = "Failed to read UUID."
            }
        }
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

            guard let url = URL(string: "https://<your-region>-<your-project-id>.cloudfunctions.net/getPatientRecord") else { return }

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

                if let json = try? JSONDecoder().decode(Patient.self, from: data) {
                    DispatchQueue.main.async {
                        self.patient = json
                        self.message = "Patient data loaded."
                    }
                } else {
                    DispatchQueue.main.async {
                        self.message = "Invalid response from server."
                    }
                }
            }.resume()
        }
    }
}
