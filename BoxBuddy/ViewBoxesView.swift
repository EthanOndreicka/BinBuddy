//
//  ViewBoxesView.swift
//  BoxBuddy
//
//  Created by Ethan Ondreicka on 10/2/25.
//

import SwiftUI
import SwiftData

struct ViewBoxesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StorageBox.dateCreated, order: .reverse) private var boxes: [StorageBox]
    @State private var searchText = ""
    
    var filteredBoxes: [StorageBox] {
        if searchText.isEmpty {
            return boxes
        }
        return boxes.filter { box in
            box.name.localizedCaseInsensitiveContains(searchText) ||
            box.boxDescription.localizedCaseInsensitiveContains(searchText) ||
            box.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) ||
            box.items.contains(where: { $0.name.localizedCaseInsensitiveContains(searchText) })
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredBoxes) { box in
                NavigationLink(destination: BoxDetailView(box: box)) {
                    BoxRowView(box: box)
                }
            }
            .onDelete(perform: deleteBoxes)
        }
        .navigationTitle("My Boxes")
        .searchable(text: $searchText, prompt: "Search boxes or items")
        .overlay {
            if boxes.isEmpty {
                ContentUnavailableView(
                    "No Boxes Yet",
                    systemImage: "shippingbox",
                    description: Text("Add your first box to get started")
                )
            }
        }
    }
    
    private func deleteBoxes(at offsets: IndexSet) {
        for index in offsets {
            let box = filteredBoxes[index]
            modelContext.delete(box)
        }
    }
}

struct BoxRowView: View {
    let box: StorageBox
    
    var body: some View {
        HStack(spacing: 15) {
            if let imageData = box.boxImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "shippingbox.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(width: 60, height: 60)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(box.name)
                    .font(.headline)
                
                if !box.boxDescription.isEmpty {
                    Text(box.boxDescription)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                HStack {
                    Image(systemName: "cube.box")
                        .font(.caption)
                    Text("\(box.items.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !box.tags.isEmpty {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(box.tags.first ?? "")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
