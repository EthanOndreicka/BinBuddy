//
//  QRCodeGenerator.swift
//  BoxBuddy
//
//  Created by Ethan Ondreicka on 10/2/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {
    static func generate(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        guard let data = string.data(using: .utf8) else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let ciImage = filter.outputImage else { return nil }
        
        // Scale up the QR code
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCIImage = ciImage.transformed(by: transform)
        
        guard let cgImage = context.createCGImage(scaledCIImage, from: scaledCIImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

struct QRCodeView: View {
    let boxID: String
    let boxName: String
    @State private var qrImage: UIImage?
    
    var body: some View {
        VStack(spacing: 20) {
            if let image = qrImage {
                VStack(spacing: 12) {
                    Text(boxName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    
                    Text("Scan this code to open this box")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            qrImage = QRCodeGenerator.generate(from: "boxbuddy://\(boxID)")
        }
    }
}

struct QRCodeDisplayView: View {
    @Environment(\.dismiss) private var dismiss
    let box: StorageBox
    let onDismiss: (() -> Void)?
    @State private var qrImage: UIImage?
    @State private var showingSaveConfirmation = false
    
    init(box: StorageBox, onDismiss: (() -> Void)? = nil) {
        self.box = box
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Print this QR code and attach it to your box")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if let image = qrImage {
                        VStack(spacing: 16) {
                            // QR Code with label
                            VStack(spacing: 12) {
                                Text(box.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Image(uiImage: image)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 300, height: 300)
                                    .padding(20)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                                
                                Text("Box ID: \(box.id.uuidString.prefix(8))...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(16)
                            
                            // Action buttons
                            VStack(spacing: 12) {
                                ShareLink(item: Image(uiImage: image), preview: SharePreview(box.name, image: Image(uiImage: image))) {
                                    Label("Share or Print", systemImage: "square.and.arrow.up")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                
                                Button(action: {
                                    saveToPhotos(image: image)
                                }) {
                                    Label("Save to Photos", systemImage: "square.and.arrow.down")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        ProgressView()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to use:")
                            .font(.headline)
                        
                        Text("1. Save or print this QR code")
                        Text("2. Attach it to your physical box")
                        Text("3. Use 'Scan QR Code' from the main menu to quickly open this box")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Box QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if let onDismiss = onDismiss {
                            onDismiss()
                        }
                        dismiss()
                    }
                }
            }
            .alert("Saved to Photos", isPresented: $showingSaveConfirmation) {
                Button("OK", role: .cancel) { }
            }
        }
        .onAppear {
            qrImage = QRCodeGenerator.generate(from: "boxbuddy://\(box.id.uuidString)")
        }
    }
    
    private func saveToPhotos(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showingSaveConfirmation = true
    }
}
