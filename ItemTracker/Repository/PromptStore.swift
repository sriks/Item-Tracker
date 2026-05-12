//
//  PromptStore.swift
//  ItemTracker
//

import Foundation

/// `UserDefaults`-backed implementation of `PromptStorable`.
/// Accepts a custom `UserDefaults` instance so tests can inject an in-memory suite
/// without touching `.standard`.
final class UserDefaultsPromptStore: PromptStorable {
    private enum Keys {
        static let currentPrompt = "customPrompt"
        static let history = "promptHistory"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var currentPrompt: String? {
        defaults.string(forKey: Keys.currentPrompt)
    }

    var promptHistory: [String] {
        defaults.stringArray(forKey: Keys.history) ?? []
    }

    func savePrompt(_ prompt: String) {
        defaults.set(prompt, forKey: Keys.currentPrompt)
        var history = promptHistory
        history.removeAll { $0 == prompt }
        history.insert(prompt, at: 0)
        if history.count > 10 { history = Array(history.prefix(10)) }
        defaults.set(history, forKey: Keys.history)
    }
}
