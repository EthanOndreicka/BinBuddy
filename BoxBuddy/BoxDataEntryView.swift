//
//  BoxDataEntryView.swift
//  BoxBuddy
//
//  Created by Ethan Ondreicka on 10/2/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct BoxDataEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var box: StorageBox
    
    @State private var showingImagePicker = false
    @State private var selectedTags: Set<String> = []
    @State private var showingAddItem = false
    @State private var showingQRCode = false
    @State private var shouldShowQROnDone = false
    
    init(box: StorageBox, showQRCodeOnComplete: Bool = false) {
        self.box = box
        self._shouldShowQROnDone = State(initialValue: showQRCodeOnComplete)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Box Information") {
                    TextField("Box Name", text: $box.name)
                    
                    TextField("Description (optional)", text: $box.boxDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Box Photo") {
                    if let imageData = box.boxImageData,
                       let uiImage = UIImage(data: imageData) {
                        HStack {
                            Spacer()
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                            Spacer()
                        }
                        
                        Button("Change Photo", systemImage: "camera") {
                            showingImagePicker = true
                        }
                    } else {
                        Button("Add Photo", systemImage: "camera") {
                            showingImagePicker = true
                        }
                    }
                }
                
                Section("Tags") {
                    ForEach(PredefinedTags.options, id: \.self) { tag in
                        Button(action: {
                            toggleTag(tag)
                        }) {
                            HStack {
                                Text(tag)
                                    .foregroundColor(.primary)
                                Spacer()
                                if box.tags.contains(tag) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section("Items") {
                    if box.items.isEmpty {
                        Text("No items added yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(box.items) { item in
                            HStack {
                                if let imageData = item.imageData,
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.body)
                                    if !item.itemDescription.isEmpty {
                                        Text(item.itemDescription)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    
                    Button("Add Item", systemImage: "plus.circle") {
                        showingAddItem = true
                    }
                }
            }
            .navigationTitle("Box Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if shouldShowQROnDone && box.qrCodeData != nil {
                            showingQRCode = true
                        } else {
                            dismiss()
                        }
                    }
                    .disabled(box.name.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                PhotoPickerView(imageData: $box.boxImageData)
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView(box: box)
            }
            .sheet(isPresented: $showingQRCode) {
                QRCodeDisplayView(box: box, onDismiss: {
                    dismiss()
                })
            }
        }
    }
    
    private func toggleTag(_ tag: String) {
        if let index = box.tags.firstIndex(of: tag) {
            box.tags.remove(at: index)
        } else {
            box.tags.append(tag)
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        box.items.remove(atOffsets: offsets)
    }
}

struct PhotoPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var imageData: Data?
    @State private var selectedImage: UIImage?
    @State private var showingPicker = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                    
                    Button("Use This Photo") {
                        if let data = image.jpegData(compressionQuality: 0.8) {
                            imageData = data
                        }
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                } else {
                    ContentUnavailableView(
                        "No Photo Selected",
                        systemImage: "photo",
                        description: Text("Take a photo to get started")
                    )
                }
            }
            .navigationTitle("Add Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Camera", systemImage: "camera") {
                        showingPicker = true
                    }
                }
            }
            .sheet(isPresented: $showingPicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
}
