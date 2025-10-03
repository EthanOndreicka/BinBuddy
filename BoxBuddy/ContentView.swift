//
//  ContentView.swift
//  BoxBuddy
//
//  Created by Ethan Ondreicka on 10/2/25.
//

import SwiftUI
import SwiftData

@main
struct StorageBinApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [StorageBox.self, BoxItem.self])
    }
}

struct ContentView: View {
    @State private var showingQRScanner = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Bin Buddy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 20) {
                    NavigationLink(destination: ViewBoxesView()) {
                        MenuButton(icon: "shippingbox", title: "View Boxes")
                    }
                    
                    Button(action: { showingQRScanner = true }) {
                        MenuButton(icon: "qrcode.viewfinder", title: "Scan QR Code")
                    }
                    
                    NavigationLink(destination: AddBoxView()) {
                        MenuButton(icon: "plus.circle", title: "Add Box")
                    }
                    
                    NavigationLink(destination: SettingsView()) {
                        MenuButton(icon: "gear", title: "Settings")
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .sheet(isPresented: $showingQRScanner) {
                QuickQRScannerView()
            }
        }
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 40)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(12)
    }
}
