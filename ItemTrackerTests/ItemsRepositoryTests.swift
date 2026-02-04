//
//  ItemsRepositoryTests.swift
//  ItemTrackerTests
//
//  Created by Claude on 29/1/2026.
//  Copyright © 2026 Dreamcode Pty Ltd. All rights reserved.
//

import Foundation
import Testing
import SwiftData
@testable import ItemTracker

/// Tests for ItemsRepository. Uses in-memory SwiftData storage for isolation.
/// Note: Run with -parallel-testing-enabled NO for reliability with SwiftData.
@Suite(.serialized)
@MainActor
struct ItemsRepositoryTests {
    // MARK: - Initialization Tests

    @Test("Repository emits empty array on init with empty container")
    func init_emptyContainer_emitsEmptyArray() async throws {
        let container = try TestHelpers.makeInMemoryContainer()
        let sut = ItemsRepository(modelContainer: container)

        var iterator = sut.itemsSharedStream.makeAsyncIterator()
        let firstEmission = try await iterator.next()

        #expect(firstEmission != nil)
        #expect(firstEmission?.isEmpty == true)
    }

    // MARK: - Add Tests

    @Test("Add single item persists and can be retrieved")
    func add_singleItem_persistsAndEmits() async throws {
        let container = try TestHelpers.makeInMemoryContainer()
        let sut = ItemsRepository(modelContainer: container)

        // Subscribe BEFORE mutation to catch all emissions
        var iterator = sut.itemsSharedStream.makeAsyncIterator()

        // Get initial empty emission
        let initial = try await iterator.next()
        #expect(initial?.isEmpty == true)

        // Add item
        try await sut.add(text: "Test item")

        // Get emission after add
        let items = try await iterator.next()
        #expect(items?.count == 1)
        #expect(items?.first?.text == "Test item")
    }

    @Test("Added item has correct default properties")
    func add_itemHasCorrectDefaults() async throws {
        let container = try TestHelpers.makeInMemoryContainer()
        let sut = ItemsRepository(modelContainer: container)
        let beforeAdd = Date()

        var iterator = sut.itemsSharedStream.makeAsyncIterator()
        _ = try await iterator.next() // Skip initial empty

        try await sut.add(text: "Test")

        let items = try await iterator.next()
        let item = try #require(items?.first)

        #expect(item.text == "Test")
        #expect(item.isSynced == false)
        #expect(item.isShared == false)
        #expect(item.createdBy == nil)
        #expect(item.timestamp >= beforeAdd)
        #expect(item.lastModified >= beforeAdd)
    }

    @Test("Multiple items are sorted by timestamp descending (newest first)")
    func add_multipleItems_sortedByTimestampDescending() async throws {
        let container = try TestHelpers.makeInMemoryContainer()
        let sut = ItemsRepository(modelContainer: container)

        var iterator = sut.itemsSharedStream.makeAsyncIterator()
        _ = try await iterator.next() // Skip initial

        // Add items with small delays to ensure different timestamps
        try await sut.add(text: "First")
        _ = try await iterator.next() // Skip intermediate

        try await Task.sleep(for: .milliseconds(10))
        try await sut.add(text: "Second")
        _ = try await iterator.next() // Skip intermediate

        try await Task.sleep(for: .milliseconds(10))
        try await sut.add(text: "Third")
        let items = try await iterator.next()

        #expect(items?.count == 3)
        #expect(items?[0].text == "Third")
        #expect(items?[1].text == "Second")
        #expect(items?[2].text == "First")
    }

    // MARK: - Delete Tests

    @Test("Delete existing item removes from storage")
    func delete_existingItem_removesFromStorage() async throws {
        let container = try TestHelpers.makeInMemoryContainer()
        let sut = ItemsRepository(modelContainer: container)

        var iterator = sut.itemsSharedStream.makeAsyncIterator()
        _ = try await iterator.next() // Skip initial

        try await sut.add(text: "To delete")

        // Get the item to delete
        let itemsAfterAdd = try await iterator.next()
        let itemToDelete = try #require(itemsAfterAdd?.first)

        // Delete
        try await sut.delete(itemToDelete)

        // Verify deletion
        let itemsAfterDelete = try await iterator.next()
        #expect(itemsAfterDelete?.isEmpty == true)
    }

    @Test("Delete last item emits empty array")
    func delete_lastItem_emitsEmptyArray() async throws {
        let container = try TestHelpers.makeInMemoryContainer()
        let sut = ItemsRepository(modelContainer: container)

        var iterator = sut.itemsSharedStream.makeAsyncIterator()
        _ = try await iterator.next() // Skip initial

        try await sut.add(text: "Only item")

        let items = try await iterator.next()
        let itemToDelete = try #require(items?.first)

        try await sut.delete(itemToDelete)

        let itemsAfterDelete = try await iterator.next()
        #expect(itemsAfterDelete?.isEmpty == true)
    }

    // MARK: - Edge Case Tests

    @Test("Add empty text persists successfully")
    func add_emptyText_persists() async throws {
        let container = try TestHelpers.makeInMemoryContainer()
        let sut = ItemsRepository(modelContainer: container)

        var iterator = sut.itemsSharedStream.makeAsyncIterator()
        _ = try await iterator.next() // Skip initial

        try await sut.add(text: "")

        let items = try await iterator.next()
        #expect(items?.first?.text == "")
    }

    @Test("Add text with special characters persists correctly")
    func add_specialCharacters_persists() async throws {
        let container = try TestHelpers.makeInMemoryContainer()
        let sut = ItemsRepository(modelContainer: container)
        let specialText = "Emoji: 🎉 Unicode: \u{00E9} Newline:\nTab:\t"

        var iterator = sut.itemsSharedStream.makeAsyncIterator()
        _ = try await iterator.next() // Skip initial

        try await sut.add(text: specialText)

        let items = try await iterator.next()
        #expect(items?.first?.text == specialText)
    }

    @Test("Add duplicate text creates separate items with different IDs")
    func add_duplicateText_createsSeparateItems() async throws {
        let container = try TestHelpers.makeInMemoryContainer()
        let sut = ItemsRepository(modelContainer: container)

        var iterator = sut.itemsSharedStream.makeAsyncIterator()
        _ = try await iterator.next() // Skip initial

        try await sut.add(text: "Duplicate")
        _ = try await iterator.next() // Skip first add emission

        try await sut.add(text: "Duplicate")

        let items = try await iterator.next()
        #expect(items?.count == 2)
        #expect(items?[0].text == "Duplicate")
        #expect(items?[1].text == "Duplicate")
        #expect(items?[0].id != items?[1].id)
    }
}
