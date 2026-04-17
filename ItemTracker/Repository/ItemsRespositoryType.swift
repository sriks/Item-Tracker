//
//  ItemsRespositoryType.swift
//  ItemTracker
//
//  Created by Srikanth on 28/1/2026.
//  Copyright © 2026 Dreamcode Pty Ltd. All rights reserved.
//

import Foundation
import AsyncAlgorithms

/// Errors that can occur during any mutating repository operation.
public enum ItemsRepositoryError: Error, Equatable {
    /// No item matching the given identifier exists in the store.
    case itemNotFound(id: String)
    /// An underlying persistence or fetch operation failed.
    case persistenceFailed(underlying: any Error)

    public static func == (lhs: ItemsRepositoryError, rhs: ItemsRepositoryError) -> Bool {
        switch (lhs, rhs) {
        case let (.itemNotFound(l), .itemNotFound(r)): l == r
        case (.persistenceFailed, .persistenceFailed): true
        default: false
        }
    }
}

public protocol ItemsFetchable {
    /// Shared async sequence of items - broadcasts to multiple subscribers
    /// Returns items sorted by timestamp (newest first)
    var itemsSharedStream: any AsyncSequence<[Item], Never> & Sendable { get }

    var allItems: [Item] { get }
}

/// Protocol for repository that manages Item persistence and streams changes
public protocol ItemsMutatable {
    /// Add a new item to the repository
    func add(text: String) async throws(ItemsRepositoryError)

    /// Delete an item by its identifier
    func delete(id: String) async throws(ItemsRepositoryError)

    /// Update the text of an existing item
    func update(id: String, newText: String) async throws(ItemsRepositoryError)
}

public typealias ItemsRepositoryType = ItemsFetchable & ItemsMutatable
