//
//  ScanningView.swift
//  BoxBuddy
//
//  Created by Ethan Ondreicka on 10/2/25.
//

import SwiftUI
import CoreNFC
import AVFoundation

struct ScanningView: View {
    let method: AddBoxView.ScanMethod
    let onComplete: (String?, String?, Data?) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack {
            switch method {
            case .nfc:
                NFCScanView(onComplete: { tagID in
                    onComplete(tagID, nil, nil)
                }, onCancel: onCancel)
                
            case .qr:
                // Immediately generate QR and complete
                Color.clear.onAppear {
                    let qrData = UUID().uuidString
                    onComplete(nil, qrData, nil)
                }
                
            case .photo:
                ImagePickerButton(onComplete: { imageData in
                    onComplete(nil, nil, imageData)
                }, onCancel: onCancel)
            }
        }
    }
}

// MARK: - NFC Scanning
struct NFCScanView: View {
    let onComplete: (String) -> Void
    let onCancel: () -> Void
    
    @State private var nfcReader: NFCReader?
    @State private var statusMessage = "Ready to scan"
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "wave.3.right.circle")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("NFC Tag Scanning")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(statusMessage)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: startNFCScanning) {
                Label("Start Scanning", systemImage: "wave.3.right")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Button("Cancel", action: onCancel)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private func startNFCScanning() {
        nfcReader = NFCReader { tagID in
            statusMessage = "Tag detected!"
            onComplete(tagID)
        }
        nfcReader?.begin()
    }
}

class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {
    var onTagDetected: (String) -> Void
    var session: NFCNDEFReaderSession?
    
    init(onTagDetected: @escaping (String) -> Void) {
        self.onTagDetected = onTagDetected
        super.init()
    }
    
    func begin() {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("NFC not available on this device")
            return
        }
        
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near the NFC tag"
        session?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Handle NDEF messages if needed
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }
        
        session.connect(to: tag) { error in
            if error != nil {
                session.invalidate(errorMessage: "Connection failed")
                return
            }
            
            tag.queryNDEFStatus { status, _, error in
                if error != nil {
                    session.invalidate(errorMessage: "Failed to read tag")
                    return
                }
                
                // Get tag identifier
                tag.readNDEF { message, error in
                    let tagID = UUID().uuidString
                    
                    DispatchQueue.main.async {
                        self.onTagDetected(tagID)
                    }
                    
                    session.alertMessage = "Tag detected!"
                    session.invalidate()
                }
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("NFC Session invalidated: \(error.localizedDescription)")
    }
}

// MARK: - QR Code Scanning
struct QRScannerView: View {
    let onComplete: (String) -> Void
    let onCancel: () -> Void
    
    @State private var isShowingScanner = true
    
    var body: some View {
        VStack {
            if isShowingScanner {
                QRCodeScannerRepresentable(onScan: { code in
                    onComplete(code)
                    isShowingScanner = false
                })
                .edgesIgnoringSafeArea(.all)
                
                Button("Cancel") {
                    onCancel()
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
        }
    }
}

struct QRCodeScannerRepresentable: UIViewControllerRepresentable {
    let onScan: (String) -> Void
    
    func makeUIViewController(context: Context) -> QRCodeScannerViewController {
        let controller = QRCodeScannerViewController()
        controller.onScan = onScan
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QRCodeScannerViewController, context: Context) {}
}

class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var onScan: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            onScan?(stringValue)
            captureSession.stopRunning()
        }
    }
}

// MARK: - Image Picker
struct ImagePickerButton: View {
    let onComplete: (Data) -> Void
    let onCancel: () -> Void
    
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 30) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                
                Button("Use This Photo") {
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        onComplete(imageData)
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Take Another Photo") {
                    showingImagePicker = true
                }
                .buttonStyle(.bordered)
            } else {
                Image(systemName: "camera")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Take a Photo of the Box")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Button(action: { showingImagePicker = true }) {
                    Label("Open Camera", systemImage: "camera")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            
            Button("Cancel", action: onCancel)
                .foregroundColor(.secondary)
        }
        .padding()
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }
    }
}
