//
//  AddItemView.swift
//  BoxBuddy
//
//  Created by Ethan Ondreicka on 10/2/25.
//

import SwiftUI
import SwiftData

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var box: StorageBox
    
    @State private var itemName = ""
    @State private var itemDescription = ""
    @State private var itemImageData: Data?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Information") {
                    TextField("Item Name", text: $itemName)
                    
                    TextField("Description (optional)", text: $itemDescription, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section("Item Photo") {
                    if let imageData = itemImageData,
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
                        Button("Add Photo (optional)", systemImage: "camera") {
                            showingImagePicker = true
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(itemName.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                PhotoPickerView(imageData: $itemImageData)
            }
        }
    }
    
    private func addItem() {
        let newItem = BoxItem(
            name: itemName,
            itemDescription: itemDescription,
            imageData: itemImageData
        )
        box.items.append(newItem)
        dismiss()
    }
}
