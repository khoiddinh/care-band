//
//  QRCodeSheet.swift
//  careband
//
//  Created by Khoi Dinh on 4/27/25.
//


import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeSheet: View {
    @Environment(\.dismiss) private var dismiss

    let uuid: String
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        VStack(spacing: 20) {
            Text("Scan to Access Patient")
                .font(.title2)
                .bold()
                .padding(.top)

            if let qrImage = generateQRCode(from: uuid) {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .cornerRadius(12)
                    .padding()
            } else {
                Text("Failed to generate QR code.")
                    .foregroundColor(.red)
            }

            Text("UUID:\n\(uuid)")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()

            Spacer()

            Button("Done") {
                dismiss() 
            }

            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding()
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        
        // Add correction level (higher = bigger QR, better scan)
        filter.setValue("M", forKey: "inputCorrectionLevel") // options: L, M, Q, H

        if let outputImage = filter.outputImage {
            let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 20, y: 20))
            
            let context = CIContext()
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }

}
