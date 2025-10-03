//
//  AddBoxView.swift
//  BoxBuddy
//
//  Created by Ethan Ondreicka on 10/2/25.
//

import SwiftUI
import SwiftData
import CoreNFC
import AVFoundation

struct AddBoxView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingScanOptions = true
    @State private var scanMethod: ScanMethod?
    @State private var newBox: StorageBox?
    @State private var shouldShowQRCode = false   // track QR flow
    
    enum ScanMethod {
        case nfc, qr, photo
    }
    
    var body: some View {
        Group {
            if showingScanOptions {
                ScanOptionsView(
                    onMethodSelected: { method in
                        scanMethod = method
                        showingScanOptions = false
                    },
                    onSkip: {
                        let box = StorageBox()
                        modelContext.insert(box)
                        newBox = box
                        showingScanOptions = false
                    }
                )
            } else if let method = scanMethod {
                ScanningView(
                    method: method,
                    onComplete: { tagID, qrData, imageData in
                        let box = StorageBox(
                            nfcTagID: tagID,
                            qrCodeData: qrData,
                            boxImageData: imageData
                        )
                        if box.qrCodeData == nil && method == .qr {
                            box.qrCodeData = box.id.uuidString
                        }
                        modelContext.insert(box)
                        newBox = box
                        shouldShowQRCode = (method == .qr)   // ✅ mark QR
                        scanMethod = nil
                    },
                    onCancel: {
                        showingScanOptions = true
                        scanMethod = nil
                    }
                )
            } else if let box = newBox {
                BoxDataEntryView(box: box, showQRCodeOnComplete: shouldShowQRCode)
            }
        }
        .navigationTitle("Add Box")
    }
}


struct ScanOptionsView: View {
    let onMethodSelected: (AddBoxView.ScanMethod) -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shippingbox.and.arrow.backward")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 40)
            
            Text("How would you like to add this box?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ScanOptionButton(
                    icon: "qrcode",
                    title: "Generate QR Code",
                    description: "Create a QR code for this box"
                ) {
                    onMethodSelected(.qr)
                }
                
                // Uncomment when have a paid account lol:
                /*
                ScanOptionButton(
                    icon: "wave.3.right.circle",
                    title: "Scan NFC Tag",
                    description: "Tap your device to an NFC tag"
                ) {
                    onMethodSelected(.nfc)
                }
                */
                
                ScanOptionButton(
                    icon: "camera",
                    title: "Take Photo",
                    description: "Take a photo of the box"
                ) {
                    onMethodSelected(.photo)
                }
                
                Button(action: onSkip) {
                    Text("Skip Scanning")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct ScanOptionButton: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}
