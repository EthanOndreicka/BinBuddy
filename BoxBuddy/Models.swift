//
//  Models.swift
//  BoxBuddy
//
//  Created by Ethan Ondreicka on 10/2/25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Data Models

@Model
final class StorageBox {
    var id: UUID
    var name: String
    var boxDescription: String
    var nfcTagID: String?
    var qrCodeData: String?
    var boxImageData: Data?
    var tags: [String]
    var dateCreated: Date
    @Relationship(deleteRule: .cascade) var items: [BoxItem]
    
    init(name: String = "", boxDescription: String = "", nfcTagID: String? = nil, qrCodeData: String? = nil, boxImageData: Data? = nil, tags: [String] = []) {
        self.id = UUID()
        self.name = name
        self.boxDescription = boxDescription
        self.nfcTagID = nfcTagID
        self.qrCodeData = qrCodeData
        self.boxImageData = boxImageData
        self.tags = tags
        self.dateCreated = Date()
        self.items = []
    }
}

@Model
final class BoxItem {
    var id: UUID
    var name: String
    var itemDescription: String
    var imageData: Data?
    var dateAdded: Date
    
    init(name: String = "", itemDescription: String = "", imageData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.itemDescription = itemDescription
        self.imageData = imageData
        self.dateAdded = Date()
    }
}

// MARK: - Predefined Tags
enum PredefinedTags {
    static let options = [
        "Kitchen",
        "Bedroom",
        "Garage",
        "Basement",
        "Attic",
        "Office",
        "Seasonal",
        "Electronics",
        "Clothes",
        "Tools",
        "Toys",
        "Books",
        "Documents",
        "Holiday Decorations",
        "Sports Equipment"
    ]
}
