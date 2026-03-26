//
//  ItemsViewModel.swift
//  ItemTracker
//
//  Created by Srikanth on 8/3/2026.
//  Copyright © 2026 Dreamcode Pty Ltd. All rights reserved.
//
import Foundation
import Observation

/// A view-ready representation of a single item, formatted for display.
///
/// All formatting is applied here so the view can bind directly to strings
/// without containing any presentation logic.
struct ItemDisplayModel: Equatable, Identifiable {
    /// Stable identifier matching the underlying `Item`.
    let id: UUID
    /// The free-form text the user saved.
    let text: String
    /// The item's creation date formatted as "DD MMM YYYY" (e.g. "24 Mar 2026").
    let formattedDate: String
}

/// Drives the Items tab, exposing a list of display-ready items sourced from the repository stream.
///
/// Subscribes to `ItemsFetchable.itemsSharedStream` on initialisation and maps each
/// emission to `ItemDisplayModel` values. The view observes `items` and re-renders
/// automatically whenever the repository emits an updated list.
@Observable @MainActor
class ItemsViewModel {
    /// The current list of items ready for display, updated on every repository emission.
    private(set) var items: [ItemDisplayModel] = []

    private let repository: ItemsFetchable
    private let mutableRepository: ItemsMutatable

    /// Creates the view model and begins observing the repository stream immediately.
    /// - Parameters:
    ///   - repository: The data source to subscribe to for fetch capability.
    ///   - mutableRepository: The data source for add/delete capability.
    init(repository: ItemsFetchable, mutableRepository: ItemsMutatable) {
        self.repository = repository
        self.mutableRepository = mutableRepository
        startObserving()
    }

    /// Adds a new item with the given text to the repository.
    func addItem(text: String) async throws {
        try await mutableRepository.add(text: text)
    }

    /// Opens a long-lived async loop that maps each repository emission to display models.
    private func startObserving() {
        Task { [weak self] in
            guard let self else { return }
            for await rawItems in repository.itemsSharedStream {
                items = rawItems.map { ItemDisplayModel(
                    id: $0.id,
                    text: $0.text,
                    formattedDate: $0.timestamp.formatted(.dateTime.day().month(.abbreviated).year())
                ) }
            }
        }
    }
}
