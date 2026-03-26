//
//  ItemsRespositoryType.swift
//  ItemTracker
//
//  Created by Srikanth on 28/1/2026.
//  Copyright © 2026 Dreamcode Pty Ltd. All rights reserved.
//

import Foundation
import AsyncAlgorithms

public protocol ItemsFetchable {
    /// Shared async sequence of items - broadcasts to multiple subscribers
    /// Returns items sorted by timestamp (newest first)
    var itemsSharedStream: any AsyncSequence<[Item], Never> & Sendable { get }
    
    var allItems: [Item] { get }
}

/// Protocol for repository that manages Item persistence and streams changes
public protocol ItemsMutatable {
    /// Add a new item to the repository
    /// - Parameter text: The item description text
    /// - Throws: SwiftData persistence errors
    func add(text: String) async throws

    /// Delete an item from the repository
    /// - Parameter item: The item to delete
    /// - Throws: SwiftData persistence errors
    func delete(_ item: Item) async throws
}

public typealias ItemsRepositoryType = ItemsFetchable & ItemsMutatable
