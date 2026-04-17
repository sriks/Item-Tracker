//
//  ItemDetailViewModel.swift
//  ItemTracker
//
//  Created by Srikanth on 26/3/2026.
//  Copyright © 2026 Dreamcode Pty Ltd. All rights reserved.
//

import Foundation
import Observation

/// Drives the Item Detail screen, managing editable state for a single item.
///
/// Holds the current edited text and delegates persistence operations to the
/// injected `ItemsMutatable` repository.
@Observable @MainActor
final class ItemDetailViewModel {
    /// The text currently shown in the editor — may differ from the saved value.
    var editedText: String

    /// The original display model this detail screen was opened with.
    let item: ItemDisplayModel

    /// `true` when `editedText` differs from the saved text.
    var hasChanges: Bool {
        editedText.trimmingCharacters(in: .whitespacesAndNewlines) != item.text
    }

    private let mutableRepository: any ItemsMutatable

    init(item: ItemDisplayModel, mutableRepository: any ItemsMutatable) {
        self.item = item
        editedText = item.text
        self.mutableRepository = mutableRepository
    }

    /// Persists the edited text if it has changed.
    func save() async throws {
        let trimmed = editedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != item.text else { return }
        try await mutableRepository.update(id: item.id, newText: trimmed)
    }

    /// Removes the item from the repository.
    func delete() async throws {
        try await mutableRepository.delete(id: item.id)
    }
}
