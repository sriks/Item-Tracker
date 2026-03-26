//
//  ItemsViewModelTests.swift
//  ItemTrackerTests
//
//  Created by Claude on 13/3/2026.
//  Copyright © 2026 Dreamcode Pty Ltd. All rights reserved.
//

import Foundation
import Testing
@testable import ItemTracker

// MARK: - Mock

/// A test double for `ItemsRepositoryType` that lets tests push item arrays on demand.
///
/// Backed by an `AsyncStream` so the mock stays in-process with no SwiftData dependency.
/// Call `emit(_:)` to push a new snapshot of items, matching what `ItemsRepository` does
/// after every add or delete.
@MainActor
private final class MockItemsRepository: ItemsRepositoryType {
    var allItems: [ItemTracker.Item] { [] }
    
    private let stream: AsyncStream<[Item]>
    private let continuation: AsyncStream<[Item]>.Continuation

    init() {
        var cont: AsyncStream<[Item]>.Continuation!
        stream = AsyncStream { cont = $0 }
        continuation = cont
    }

    var itemsSharedStream: any AsyncSequence<[Item], Never> & Sendable {
        stream
    }

    /// Pushes a new list of items to all active subscribers.
    func emit(_ items: [Item]) {
        continuation.yield(items)
    }

    func add(text: String) async throws {}
    func delete(_ item: Item) async throws {}
}

// MARK: - Tests

/// Unit tests for `ItemsViewModel`.
///
/// Tests run serially (`@Suite(.serialized)`) to avoid cross-test interference from
/// shared MainActor state. Each test creates its own mock and view model in isolation.
///
/// Async assertions use `waitUntil` instead of a single `Task.yield()` because the
/// inner observation task spawned by the view model needs at least one scheduling cycle
/// to process each stream emission — and that is not guaranteed in a single yield.
@Suite(.serialized)
@MainActor
struct ItemsViewModelTests {
    /// Yields repeatedly until `condition` becomes true, up to 20 scheduling cycles.
    ///
    /// Used to wait for the view model's internal observation task to process a stream
    /// emission before asserting on `items`.
    private func waitUntil(_ condition: @autoclosure () -> Bool) async {
        for _ in 0..<20 {
            if condition() { return }
            await Task.yield()
        }
    }

    @Test("Starts with empty items before any stream emission")
    func startsEmpty() {
        let mock = MockItemsRepository()
        let sut = ItemsViewModel(repository: mock, mutableRepository: mock)
        #expect(sut.items.isEmpty)
    }

    @Test("Items populate after stream emits")
    func populatesItemsAfterEmission() async {
        let mock = MockItemsRepository()
        let sut = ItemsViewModel(repository: mock, mutableRepository: mock)

        let item = try! Item(text: "Toilet paper in storage")
        mock.emit([item])
        await waitUntil(sut.items.count == 1)

        #expect(sut.items.count == 1)
        #expect(sut.items.first?.text == "Toilet paper in storage")
    }

    @Test("Display model maps id correctly from Item")
    func mapsIdFromItem() async {
        let mock = MockItemsRepository()
        let sut = ItemsViewModel(repository: mock, mutableRepository: mock)

        let item = try! Item(text: "Keys on shelf")
        let capturedId = item.id
        mock.emit([item])
        await waitUntil(!sut.items.isEmpty)

        #expect(sut.items.first?.id == capturedId)
    }

    /// Injects a fixed date (24 Mar 2026) to assert the exact formatted string
    /// independently of when the test runs.
    @Test("Formatted date uses DD MMM YYYY format")
    func formattedDateUsesExpectedFormat() async throws {
        let mock = MockItemsRepository()
        let sut = ItemsViewModel(repository: mock, mutableRepository: mock)

        var components = DateComponents()
        components.day = 24
        components.month = 3
        components.year = 2_026
        let fixedDate = try #require(Calendar.current.date(from: components))
        let item = try! Item(text: "Test", timestamp: fixedDate)
        mock.emit([item])
        await waitUntil(!sut.items.isEmpty)

        #expect(sut.items.first?.formattedDate == "24 Mar 2026")
    }

    @Test("Items update on subsequent stream emissions")
    func updatesItemsOnSubsequentEmissions() async {
        let mock = MockItemsRepository()
        let sut = ItemsViewModel(repository: mock, mutableRepository: mock)

        let first = try! Item(text: "First")
        mock.emit([first])
        await waitUntil(sut.items.count == 1)
        #expect(sut.items.count == 1)

        let second = try! Item(text: "Second")
        mock.emit([first, second])
        await waitUntil(sut.items.count == 2)
        #expect(sut.items.count == 2)
    }

    @Test("Empty emission clears existing items")
    func clearsItemsOnEmptyEmission() async {
        let mock = MockItemsRepository()
        let sut = ItemsViewModel(repository: mock, mutableRepository: mock)

        mock.emit([try! Item(text: "Something")])
        await waitUntil(sut.items.count == 1)
        #expect(sut.items.count == 1)

        mock.emit([])
        await waitUntil(sut.items.isEmpty)
        #expect(sut.items.isEmpty)
    }
}
