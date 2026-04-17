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

/// Tests for ItemsRepository. Uses in-memory SwiftData storage via `TestHelpers.withRepository`,
/// which scopes each repository to the test closure lifetime to prevent state leakage.
@Suite(.serialized)
@MainActor
struct ItemsRepositoryTests {
    // MARK: - Initialization Tests

    @Test("Repository emits empty array on init with empty container")
    func init_emptyContainer_emitsEmptyArray() async throws {
        try await TestHelpers.withRepository { sut in
            var iterator = sut.itemsSharedStream.makeAsyncIterator()
            let firstEmission = try await iterator.next()
            #expect(firstEmission?.isEmpty == true)
        }
    }

    // MARK: - Add Tests

    @Test("Add single item persists and emits")
    func add_singleItem_persistsAndEmits() async throws {
        try await TestHelpers.withRepository { sut in
            var iterator = sut.itemsSharedStream.makeAsyncIterator()
            _ = try await iterator.next() // skip initial empty

            try await sut.add(text: "Test item")

            let items = try await iterator.next()
            #expect(items?.count == 1)
            #expect(items?.first?.text == "Test item")
        }
    }

    @Test("Added item has correct default properties")
    func add_itemHasCorrectDefaults() async throws {
        try await TestHelpers.withRepository { sut in
            let beforeAdd = Date()
            var iterator = sut.itemsSharedStream.makeAsyncIterator()
            _ = try await iterator.next()

            try await sut.add(text: "Test")

            let item = try #require(try await iterator.next()?.first)
            #expect(item.text == "Test")
            #expect(item.isSynced == false)
            #expect(item.isShared == false)
            #expect(item.createdBy == nil)
            #expect(item.timestamp >= beforeAdd)
            #expect(item.lastModified >= beforeAdd)
        }
    }

    @Test("Multiple items are sorted by timestamp descending")
    func add_multipleItems_sortedByTimestampDescending() async throws {
        try await TestHelpers.withRepository { sut in
            var iterator = sut.itemsSharedStream.makeAsyncIterator()
            _ = try await iterator.next()

            try await sut.add(text: "First")
            _ = try await iterator.next()
            try await Task.sleep(for: .milliseconds(10))

            try await sut.add(text: "Second")
            _ = try await iterator.next()
            try await Task.sleep(for: .milliseconds(10))

            try await sut.add(text: "Third")
            let items = try await iterator.next()

            #expect(items?.count == 3)
            #expect(items?[0].text == "Third")
            #expect(items?[1].text == "Second")
            #expect(items?[2].text == "First")
        }
    }

    @Test("Adding empty text throws persistenceFailed")
    func add_emptyText_throwsPersistenceFailed() async throws {
        try await TestHelpers.withRepository { sut in
            do {
                try await sut.add(text: "")
                Issue.record("Expected persistenceFailed to be thrown")
            } catch ItemsRepositoryError.persistenceFailed {
                // expected
            }
        }
    }

    @Test("Add text with special characters persists correctly")
    func add_specialCharacters_persists() async throws {
        try await TestHelpers.withRepository { sut in
            let specialText = "Emoji: 🎉 Unicode: \u{00E9} Newline:\nTab:\t"
            var iterator = sut.itemsSharedStream.makeAsyncIterator()
            _ = try await iterator.next()

            try await sut.add(text: specialText)

            let items = try await iterator.next()
            #expect(items?.first?.text == specialText)
        }
    }

    @Test("Adding item with duplicate text stores only one item")
    func add_duplicateText_storesOnlyOneItem() async throws {
        try await TestHelpers.withRepository { sut in
            // Same text produces the same SHA256 id — SwiftData upserts on the unique
            // constraint rather than throwing, so only one item ends up in the store.
            try await sut.add(text: "Duplicate")
            try await sut.add(text: "Duplicate")
            #expect(sut.allItems.count == 1)
        }
    }

    // MARK: - Delete Tests

    @Test("Delete existing item removes it from storage")
    func delete_existingItem_removesFromStorage() async throws {
        try await TestHelpers.withRepository { sut in
            var iterator = sut.itemsSharedStream.makeAsyncIterator()
            _ = try await iterator.next()

            try await sut.add(text: "To delete")
            let item = try #require(try await iterator.next()?.first)

            try await sut.delete(id: item.id)

            let itemsAfterDelete = try await iterator.next()
            #expect(itemsAfterDelete?.isEmpty == true)
        }
    }

    @Test("Delete last item emits empty array")
    func delete_lastItem_emitsEmptyArray() async throws {
        try await TestHelpers.withRepository { sut in
            var iterator = sut.itemsSharedStream.makeAsyncIterator()
            _ = try await iterator.next()

            try await sut.add(text: "Only item")
            let item = try #require(try await iterator.next()?.first)

            try await sut.delete(id: item.id)

            #expect(try await iterator.next()?.isEmpty == true)
        }
    }

    @Test("Delete with unknown id throws itemNotFound")
    func delete_unknownId_throwsItemNotFound() async throws {
        try await TestHelpers.withRepository { sut in
            let unknownId = "does-not-exist"
            do {
                try await sut.delete(id: unknownId)
                Issue.record("Expected itemNotFound to be thrown")
            } catch ItemsRepositoryError.itemNotFound(let id) {
                #expect(id == unknownId)
            }
        }
    }

    // MARK: - Update Tests

    @Test("Update existing item persists new text")
    func update_existingItem_persistsNewText() async throws {
        try await TestHelpers.withRepository { sut in
            var iterator = sut.itemsSharedStream.makeAsyncIterator()
            _ = try await iterator.next()

            try await sut.add(text: "Original text")
            let item = try #require(try await iterator.next()?.first)

            try await sut.update(id: item.id, newText: "Updated text")

            let updated = try await iterator.next()
            #expect(updated?.first?.text == "Updated text")
        }
    }

    @Test("Update refreshes lastModified date")
    func update_existingItem_refreshesLastModified() async throws {
        try await TestHelpers.withRepository { sut in
            var iterator = sut.itemsSharedStream.makeAsyncIterator()
            _ = try await iterator.next()

            try await sut.add(text: "Original")
            let item = try #require(try await iterator.next()?.first)
            let originalModified = item.lastModified

            try await Task.sleep(for: .milliseconds(10))
            try await sut.update(id: item.id, newText: "Updated")

            let updated = try #require(try await iterator.next()?.first)
            #expect(updated.lastModified > originalModified)
        }
    }

    @Test("Update with unknown id throws itemNotFound")
    func update_unknownId_throwsItemNotFound() async throws {
        try await TestHelpers.withRepository { sut in
            let unknownId = "does-not-exist"
            do {
                try await sut.update(id: unknownId, newText: "anything")
                Issue.record("Expected itemNotFound to be thrown")
            } catch ItemsRepositoryError.itemNotFound(let id) {
                #expect(id == unknownId)
            }
        }
    }
}
