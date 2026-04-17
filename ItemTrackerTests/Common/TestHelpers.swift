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

    /// Runs `body` with a freshly created, fully isolated `ItemsRepository`.
    ///
    /// The repository and its underlying in-memory container are scoped to the
    /// lifetime of the closure — they are released as soon as `body` returns,
    /// preventing any state from leaking between tests.
    @MainActor
    public static func withRepository<T>(_ body: (ItemsRepository) async throws -> T) async throws -> T {
        let container = try makeInMemoryContainer()
        let repository = ItemsRepository(modelContainer: container)
        return try await body(repository)
    }
}
