//
//  QuickQRScannerView.swift
//  BoxBuddy
//
//  Created by Ethan Ondreicka on 10/2/25.
//

import SwiftUI
import SwiftData

struct QuickQRScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var boxes: [StorageBox]
    
    @State private var scannedBoxID: String?
    @State private var foundBox: StorageBox?
    @State private var showingBoxDetail = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                QRCodeScannerRepresentable(onScan: { code in
                    handleScannedCode(code)
                })
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    if let error = errorMessage {
                        Text(error)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    }
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                }
            }
            .navigationTitle("Scan Box QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingBoxDetail) {
                if let box = foundBox {
                    NavigationStack {
                        BoxDetailView(box: box)
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Done") {
                                        dismiss()
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
    
    private func handleScannedCode(_ code: String) {
        // Extract box ID from QR code (format: "boxbuddy://UUID")
        guard code.hasPrefix("boxbuddy://") else {
            errorMessage = "Invalid QR code"
            return
        }
        
        let boxIDString = String(code.dropFirst("boxbuddy://".count))
        
        guard let boxUUID = UUID(uuidString: boxIDString) else {
            errorMessage = "Invalid box ID"
            return
        }
        
        // Find the box
        if let box = boxes.first(where: { $0.id == boxUUID }) {
            foundBox = box
            showingBoxDetail = true
            errorMessage = nil
        } else {
            errorMessage = "Box not found"
        }
    }
}
