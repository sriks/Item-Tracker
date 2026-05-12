//
//  PromptStoreType.swift
//  ItemTracker
//

import Foundation

/// Read-only access to the active custom prompt.
/// Injected into `ReasoningBrain` so it only declares the capability it actually needs.
protocol PromptReadable: AnyObject {
    /// The user-saved prompt, or `nil` if no custom prompt has been set (fall back to default).
    var currentPrompt: String? { get }
}

/// Full prompt management: read, write, and history.
/// Used by the Settings UI layer; not exposed to the AI layer.
protocol PromptStorable: PromptReadable {
    /// The last 10 saved prompts, most recent first.
    var promptHistory: [String] { get }
    /// Persists `prompt` as the active prompt and prepends it to history (capped at 10, deduped).
    func savePrompt(_ prompt: String)
}
