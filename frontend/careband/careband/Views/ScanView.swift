//
//  ScanView.swift
//  careband
//
//  Created by Khoi Dinh on 4/25/25.
//
import SwiftUI

struct ScanView: View {
    @State var nfcViewModel = NFCScanViewModel()
    @State var qrViewModel = QRScanViewModel()
    
    @State private var isShowingPatientSheet = false
    @State private var selectedPatient: Patient?

    var body: some View {
        VStack(spacing: 30) {
            
            if !isShowingPatientSheet {
                if !nfcViewModel.message.isEmpty && nfcViewModel.message != "Tap scan to begin." {
                    Text(nfcViewModel.message)
                        .foregroundColor(.gray)
                } else if !qrViewModel.message.isEmpty && qrViewModel.message != "Tap scan to begin." {
                    Text(qrViewModel.message)
                        .foregroundColor(.gray)
                } else {
                    Text("Tap scan to begin.")
                        .foregroundColor(.gray)
                }
            }

            VStack(spacing: 20) {
                Button(action: {
                    nfcViewModel.startNFCScan()
                }) {
                    Text("Scan NFC Bracelet")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button(action: {
                    qrViewModel.startQRScan()
                }) {
                    Text("Scan QR Code")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            Spacer()
        }
        .fullScreenCover(isPresented: $qrViewModel.isShowingQRScanner) {
            QRScannerView(isPresented: $qrViewModel.isShowingQRScanner) { scannedUUID in
                qrViewModel.handleScannedUUID(scannedUUID)
            }
        }
        .sheet(item: $selectedPatient) { patient in
            PatientDetailSheet(patient: patient)
        }
        .onChange(of: nfcViewModel.patient) { _, newPatient in
            if let newPatient = newPatient {
                selectedPatient = newPatient
                isShowingPatientSheet = true
            }
        }
        .onChange(of: qrViewModel.patient) { _, newPatient in
            if let newPatient = newPatient {
                selectedPatient = newPatient
                isShowingPatientSheet = true
            }
        }
        .navigationTitle("Scan Patient")
    }
}
