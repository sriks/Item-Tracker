//
//  ItemsRepository.swift
//  ItemTracker
//
//  Created by Srikanth on 28/1/2026.
//  Copyright © 2026 Dreamcode Pty Ltd. All rights reserved.
//

import AsyncAlgorithms
import Foundation
import SwiftData

/// Repository acting as the data gateway for all items. Takes care of persisting. View model should use this.
@MainActor
public final class ItemsRepository: ItemsFetchable {
    // MARK: - Dependencies
    private let modelContext: ModelContext

    // MARK: - Cached State
    private var cachedItems: [Item] = []

    // MARK: - Stream infra
    private let itemsStream: AsyncStream<[Item]>
    private let itemsStreamContinuation: AsyncStream<[Item]>.Continuation

    // MARK: - API
    public let itemsSharedStream: any AsyncSequence<[Item], Never> & Sendable

    public init(modelContainer: ModelContainer) {
        let (stream, continuation) = AsyncStream<[Item]>.makeStream()
        itemsStream = stream
        itemsStreamContinuation = continuation
        modelContext = modelContainer.mainContext
        itemsSharedStream = itemsStream.share()
        try? refreshAndEmit()
    }

    deinit {
        itemsStreamContinuation.finish()
    }

    public var allItems: [Item] {
        cachedItems
    }

    /// Refreshes items by fetching from data store and updating the stream.
    private func refreshAndEmit() throws {
        let descriptor = FetchDescriptor<Item>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        do {
            cachedItems = try modelContext.fetch(descriptor)
            itemsStreamContinuation.yield(cachedItems)
        } catch {
            print("ItemsRepository.loadItems: \(error)")
            throw error
        }
    }
}

extension ItemsRepository: ItemsMutatable {
    public func add(text: String) async throws(ItemsRepositoryError) {
        let toAdd: Item
        do {
            toAdd = try Item(text: text)
        } catch {
            throw .persistenceFailed(underlying: error)
        }
        do {
            modelContext.insert(toAdd)
            try modelContext.save()
            try refreshAndEmit()
        } catch {
            throw .persistenceFailed(underlying: error)
        }
    }

    public func delete(id: String) async throws(ItemsRepositoryError) {
        let descriptor = FetchDescriptor<Item>(predicate: #Predicate { $0.id == id })
        guard let item = (try? modelContext.fetch(descriptor))?.first else {
            throw .itemNotFound(id: id)
        }
        do {
            modelContext.delete(item)
            try modelContext.save()
            try refreshAndEmit()
        } catch {
            throw .persistenceFailed(underlying: error)
        }
    }

    public func update(id: String, newText: String) async throws(ItemsRepositoryError) {
        let descriptor = FetchDescriptor<Item>(predicate: #Predicate { $0.id == id })
        guard let item = (try? modelContext.fetch(descriptor))?.first else {
            throw .itemNotFound(id: id)
        }
        do {
            item.text = newText
            item.lastModified = Date()
            try modelContext.save()
            try refreshAndEmit()
        } catch {
            throw .persistenceFailed(underlying: error)
        }
    }
}
