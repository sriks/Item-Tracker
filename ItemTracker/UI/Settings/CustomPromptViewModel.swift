//
//  CustomPromptViewModel.swift
//  ItemTracker
//

import Foundation
import Observation

@Observable @MainActor
final class CustomPromptViewModel {
    /// The prompt text currently displayed in the editor.
    var editingPrompt: String
    private(set) var savedSuccessfully = false
    private let store: PromptStorable

    init(store: PromptStorable) {
        self.store = store
        editingPrompt = store.currentPrompt ?? ReasoningBrain.defaultInstructions
    }

    /// `true` when `editingPrompt` differs from the persisted value, enabling the save button.
    var hasChanges: Bool {
        editingPrompt != (store.currentPrompt ?? ReasoningBrain.defaultInstructions)
    }

    var promptHistory: [String] {
        store.promptHistory
    }

    func savePrompt() {
        store.savePrompt(editingPrompt)
        savedSuccessfully = true
    }

    /// Replaces the editor text with a prompt selected from history.
    func apply(historyPrompt: String) {
        editingPrompt = historyPrompt
    }
}
