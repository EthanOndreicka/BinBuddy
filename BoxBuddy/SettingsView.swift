//
//  SettingsView.swift
//  BoxBuddy
//
//  Created by Ethan Ondreicka on 10/2/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var boxes: [StorageBox]
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        Form {
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("0.1.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Total Boxes")
                    Spacer()
                    Text("\(boxes.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Total Items")
                    Spacer()
                    Text("\(totalItemCount)")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Data Management") {
                Button(role: .destructive, action: {
                    showingDeleteConfirmation = true
                }) {
                    Label("Delete All Data", systemImage: "trash")
                }
            }
            
            Section {
                Link(destination: URL(string: "https://support.apple.com/guide/iphone/use-nfc-tag-reader-iph2e50de89d/ios")!) {
                    Label("Learn About NFC", systemImage: "wave.3.right")
                }
            } header: {
                Text("Help")
            }
        }
        .navigationTitle("Settings")
        .alert("Delete All Data?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("This will permanently delete all boxes and items. This action cannot be undone.")
        }
    }
    
    private var totalItemCount: Int {
        boxes.reduce(0) { $0 + $1.items.count }
    }
    
    private func deleteAllData() {
        for box in boxes {
            modelContext.delete(box)
        }
    }
}
