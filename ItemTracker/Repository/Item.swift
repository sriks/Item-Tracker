//
//  Item.swift
//  ItemTracker
//
//  Created by Srikanth on 28/1/2026.
//  Copyright © 2026 Dreamcode Pty Ltd. All rights reserved.
//

import Foundation
import SwiftData

/// A model representing an Item and saved into persistent store.
@Model
public final class Item: Sendable {
    @Attribute(.unique) public var id: UUID
    /// user added free form text
    public var text: String
    public var timestamp: Date
    public var lastModified: Date

    // Future CloudKit fields
    public var isSynced = false
    /// Person who created it. Useful in family sharing environment.
    public var createdBy: String?
    /// Indicates is this item can be shared in a family group.
    public var isShared = false

    init(text: String, createdBy: String? = nil) {
        id = UUID()
        self.text = text
        timestamp = Date()
        lastModified = Date()
        self.createdBy = createdBy
        isSynced = false
        isShared = false
    }
}
