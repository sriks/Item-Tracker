//
//  DependencyContainer.swift
//  ItemTracker
//
//  Created by Claude Code
//

import SwiftUI

/// Protocol defining app-level dependencies
protocol DependencyContaining {
    var itemFinder: ItemFindable { get }
}

/// Concrete implementation of dependency container
/// Follows pattern from Stubs/Helpers.swift
@MainActor
final class DependencyContainer: DependencyContaining {
    let itemFinder: ItemFindable

    private init(itemFinder: ItemFindable) {
        self.itemFinder = itemFinder
    }

    /// Factory method for production container
    /// Loads inputs from JSON via Helpers
    static func production() throws -> DependencyContainer {
        guard let notes = Helpers.inputs() else {
            throw DependencyContainerError.failedToLoadInputs
        }
        let brain = ReasoningBrain(notes: notes, instructions: nil)
        return DependencyContainer(itemFinder: brain)
    }

    /// Factory method for preview/testing
    static func preview() -> DependencyContainer {
        let notes = [
            InputItem(text: "Kept toilet papers in 2nd row in storage area"),
            InputItem(text: "Batteries are in the kitchen drawer")
        ]
        let brain = ReasoningBrain(notes: notes, instructions: nil)
        return DependencyContainer(itemFinder: brain)
    }
}

enum DependencyContainerError: Error {
    case failedToLoadInputs
}

/// Environment key for dependency injection
private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue: DependencyContainer? = nil
}

extension EnvironmentValues {
    var dependencies: DependencyContainer? {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
