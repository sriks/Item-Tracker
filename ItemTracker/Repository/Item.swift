//
//  Item.swift
//  ItemTracker
//
//  Created by Srikanth on 28/1/2026.
//  Copyright © 2026 Dreamcode Pty Ltd. All rights reserved.
//

import Foundation
import SwiftData
import CryptoKit

/// The persisted representation of a user-saved item.
///
/// Each item holds free-form text describing where something is stored.
/// The repository layer is responsible for reading and writing `Item` values;
/// call sites such as view models should not interact with SwiftData directly.
@Model
public final class Item: Sendable {
    public enum Error: Swift.Error {
        case emptyText
    }

    /// Unique identifier for this item. Marked unique in the SwiftData store to prevent duplicates.
    @Attribute(.unique) public var id: String
    /// The free-form text the user entered, e.g. "Toilet paper in 2nd row of storage area".
    public var text: String
    /// When the item was first created.
    public var timestamp: Date
    /// When the item was last modified.
    public var lastModified: Date

    // Future CloudKit fields
    public var isSynced = false
    /// The person who created this item. Useful in a family-sharing environment.
    public var createdBy: String?
    /// Whether this item can be shared within a family group.
    public var isShared = false

    /// Creates a new item with the given text.
    /// - Parameters:
    ///   - text: The free-form description to store.
    ///   - timestamp: Creation date. Defaults to now; pass a fixed value in tests for determinism.
    ///   - createdBy: Optional name of the person creating the item.
    init(text: String, timestamp: Date = Date(), createdBy: String? = nil) throws(Error) {
        guard !text.isEmpty else {
            debugPrint("Cannot add item because it is empty.")
            throw .emptyText
        }
        id = Self.persistentHashString(text)
        self.text = text
        self.timestamp = timestamp
        lastModified = timestamp
        self.createdBy = createdBy
        isSynced = false
        isShared = false
    }
}

extension Item {
    /// Generates a persistent hash string for the same input.
    static func persistentHashString(_ input: String) -> String {
        let data = Data(input.utf8)
        let digest = SHA256.hash(data: data)

        // Convert the digest to a hex string for easy storage/comparison
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}
