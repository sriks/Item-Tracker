//
//  DependencyContainer.swift
//  ItemTracker
//
//  Created by Claude Code
//

import SwiftUI
import SwiftData

/// Protocol defining app-level dependencies
protocol DependencyContaining {
    var itemFinder: ItemFindable { get }
    var itemsRepository: ItemsRepositoryType { get }
}

/// Concrete implementation of dependency container
@MainActor
final class DependencyContainer: DependencyContaining {
    let itemFinder: ItemFindable
    let itemsRepository: ItemsRepositoryType
    let modelContainer: ModelContainer

    private init(modelContainer: ModelContainer, itemsRepository: ItemsRepositoryType, itemFinder: ItemFindable) {
        self.modelContainer = modelContainer
        self.itemsRepository = itemsRepository
        self.itemFinder = itemFinder
    }

    /// Factory method for production container
    /// Uses persistent SwiftData storage
    static func production() throws -> DependencyContainer {
        let modelContainer = try ModelContainer(for: Item.self)
        let repository = ItemsRepository(modelContainer: modelContainer)
        let brain = ReasoningBrain(itemsRepository: repository, instructions: nil)
        return DependencyContainer(
            modelContainer: modelContainer,
            itemsRepository: repository,
            itemFinder: brain
        )
    }

    /// Factory method for preview/testing
    /// Uses in-memory storage pre-populated with sample data
    static func preview() throws -> DependencyContainer {
        let modelContainer = try ModelContainer(
            for: Item.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let repository = ItemsRepository(modelContainer: modelContainer)

        // Pre-populate with sample data from JSON or hardcoded items
        let sampleItems = Helpers.inputs() ?? [
            TextContent(text: "Kept toilet papers in 2nd row in storage area"),
            TextContent(text: "Batteries are in the kitchen drawer")
        ]

        // Add items to the repository
        Task {
            for item in sampleItems {
                try? await repository.add(text: item.text)
            }
        }

        let brain = ReasoningBrain(itemsRepository: repository, instructions: nil)
        return DependencyContainer(
            modelContainer: modelContainer,
            itemsRepository: repository,
            itemFinder: brain
        )
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
