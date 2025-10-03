//
//  BoxDetailsView.swift
//  BoxBuddy
//
//  Created by Ethan Ondreicka on 10/2/25.
//

import SwiftUI
import SwiftData

struct BoxDetailView: View {
    @Bindable var box: StorageBox
    @State private var showingAddItem = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Box Image
                if let imageData = box.boxImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Box Info
                VStack(alignment: .leading, spacing: 12) {
                    Text(box.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if !box.boxDescription.isEmpty {
                        Text(box.boxDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    if !box.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(box.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                    
                    if box.nfcTagID != nil {
                        HStack {
                            Image(systemName: "wave.3.right")
                            Text("NFC Tag Linked")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if box.qrCodeData != nil {
                        HStack {
                            Image(systemName: "qrcode")
                            Text("QR Code Linked")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Divider()
                
                // Items Section
                HStack {
                    Text("Items (\(box.items.count))")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                
                if box.items.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "cube.box")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No items yet")
                            .foregroundColor(.secondary)
                        Button("Add First Item") {
                            showingAddItem = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(box.items) { item in
                            ItemRowView(item: item)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Box Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddItem) {
            AddItemView(box: box)
        }
    }
}

struct ItemRowView: View {
    let item: BoxItem
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageData = item.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "cube")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                if !item.itemDescription.isEmpty {
                    Text(item.itemDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}
