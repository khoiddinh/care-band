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

    @State private var selectedPatient: Patient?
    @State private var isNavigatingToPatientAction = false

    @State private var isScanningNFC = false
    @State private var isScanningQR = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 10)

            statusCard()

            Spacer()

            VStack(spacing: 20) {
                scanButton(
                    title: "Scan NFC Bracelet",
                    systemImage: "dot.radiowaves.left.and.right",
                    color: .blue,
                    isLoading: isScanningNFC,
                    action: {
                        triggerHaptic()
                        isScanningNFC = true
                        nfcViewModel.startNFCScan()
                    }
                )

                scanButton(
                    title: "Scan QR Code",
                    systemImage: "qrcode.viewfinder",
                    color: .green,
                    isLoading: isScanningQR,
                    action: {
                        triggerHaptic()
                        isScanningQR = true
                        qrViewModel = QRScanViewModel()
                        qrViewModel.startQRScan()
                    }
                )
            }
            .padding(.horizontal)

            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Scan Patient")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isNavigatingToPatientAction) {
            if let patient = selectedPatient {
                PatientActionView(patient: patient)
            }
        }
        .fullScreenCover(isPresented: $qrViewModel.isShowingQRScanner) {
            QRScannerView(isPresented: $qrViewModel.isShowingQRScanner) { scannedUUID in
                qrViewModel.handleScannedUUID(scannedUUID)
                isScanningQR = false // ✅ Reset loading when QR scanned
            }
            .onDisappear {
                if isScanningQR {
                    isScanningQR = false // ✅ Reset loading if user cancels QR scan
                }
            }
        }
        .onChange(of: nfcViewModel.patient) { _, newPatient in
            if let newPatient = newPatient {
                selectedPatient = newPatient
                isNavigatingToPatientAction = true
                isScanningNFC = false // ✅ Reset loading when NFC scanned
            }
        }
        .onChange(of: qrViewModel.patient) { _, newPatient in
            if let newPatient = newPatient {
                selectedPatient = newPatient
                isNavigatingToPatientAction = true
                isScanningQR = false // ✅ Reset loading when QR scanned
            }
        }
        .onChange(of: nfcViewModel.didFailScan) { _, didFail in
            if didFail {
                isScanningNFC = false // ✅ Reset loading if NFC fails
                nfcViewModel.didFailScan = false
            }
        }
        .onChange(of: qrViewModel.didFailScan) { _, didFail in
            if didFail {
                isScanningQR = false // ✅ Reset loading if QR fails
                qrViewModel.didFailScan = false
            }
        }
    }

    @ViewBuilder
    private func statusCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status")
                .font(.headline)
                .foregroundColor(.primary)

            Group {
                if !nfcViewModel.message.isEmpty && nfcViewModel.message != "Tap scan to begin." {
                    Text(nfcViewModel.message)
                        .foregroundColor(.secondary)
                } else if !qrViewModel.message.isEmpty && qrViewModel.message != "Tap scan to begin." {
                    Text(qrViewModel.message)
                        .foregroundColor(.secondary)
                } else {
                    Text("Tap a scan button to begin.")
                        .foregroundColor(.secondary)
                }
            }
            .font(.body)
            .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func scanButton(title: String, systemImage: String, color: Color, isLoading: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            if !isLoading {
                action()
            }
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: systemImage)
                        .font(.title2)
                    Text(isLoading ? "Scanning..." : title)
                        .font(.headline)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(isLoading ? 0.6 : 1.0))
            .cornerRadius(16)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(isLoading ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: isLoading)
        }
        .disabled(isLoading)
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}
