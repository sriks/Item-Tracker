//
//  TestHelpers.swift
//  ItemTrackerTests
//
//  Created by Claude on 29/1/2026.
//  Copyright © 2026 Dreamcode Pty Ltd. All rights reserved.
//

import Foundation
import SwiftData
@testable import ItemTracker

/// Common test utilities shared across all test files
public enum TestHelpers {
    /// Creates an in-memory ModelContainer for isolated testing.
    /// Each call returns a fresh container with no persisted data.
    @MainActor
    public static func makeInMemoryContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Item.self,
            configurations: configuration
        )
    }

    /// Creates an ItemsRepository backed by in-memory storage for testing.
    @MainActor
    public static func makeItemsRepository() throws -> ItemsRepository {
        let container = try makeInMemoryContainer()
        return ItemsRepository(modelContainer: container)
    }
}
