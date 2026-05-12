//
//  DependencyContainer.swift
//  ItemTracker
//

import SwiftUI
import SwiftData

/// Protocol defining app-level dependencies
protocol DependencyContaining {
    var itemFinder: ItemFindable { get }
    var itemsRepository: ItemsRepositoryType { get }
    var promptStore: PromptStorable { get }
}

/// Concrete implementation of dependency container
@MainActor
final class DependencyContainer: DependencyContaining {
    let itemFinder: ItemFindable
    let itemsRepository: ItemsRepositoryType
    let promptStore: PromptStorable
    let modelContainer: ModelContainer

    private init(
        modelContainer: ModelContainer,
        itemsRepository: ItemsRepositoryType,
        itemFinder: ItemFindable,
        promptStore: PromptStorable
    ) {
        self.modelContainer = modelContainer
        self.itemsRepository = itemsRepository
        self.itemFinder = itemFinder
        self.promptStore = promptStore
    }

    /// Factory method for production container
    /// Uses persistent SwiftData storage
    static func production() throws -> DependencyContainer {
        let modelContainer = try ModelContainer(for: Item.self)
        let shouldPopulateWithData: Bool = {
            #if targetEnvironment(simulator)
                return true
            #else
                // Populating with pre canned data for dev builds.
                // TODO: Remove or control this via a flag.
                return true
            #endif
        }()

        if shouldPopulateWithData {
            // Seed with sample data only in simulator
            populateWithCannedData(modelContainer: modelContainer)
        }

        let repository = ItemsRepository(modelContainer: modelContainer)
        let promptStore = UserDefaultsPromptStore()
        let brain = ReasoningBrain(itemsRepository: repository, promptStore: promptStore)
        return DependencyContainer(
            modelContainer: modelContainer,
            itemsRepository: repository,
            itemFinder: brain,
            promptStore: promptStore
        )
    }

    /// Factory method for preview/testing
    /// Uses in-memory storage pre-populated with sample data
    @MainActor
    static func preview() throws -> DependencyContainer {
        let modelContainer = try ModelContainer(
            for: Item.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        // Pre-populate with sample data from JSON or fallback items
        let sampleItems = Helpers.inputs() ?? [
            try! Item(text: "Kept toilet papers in 2nd row in storage area"),
            try! Item(text: "Batteries are in the kitchen drawer"),
        ]

        // Insert items directly into context
        let context = modelContainer.mainContext
        for item in sampleItems {
            context.insert(item)
        }
        try? context.save()

        let repository = ItemsRepository(modelContainer: modelContainer)
        let promptStore = UserDefaultsPromptStore()
        let brain = ReasoningBrain(itemsRepository: repository, promptStore: promptStore)
        return DependencyContainer(
            modelContainer: modelContainer,
            itemsRepository: repository,
            itemFinder: brain,
            promptStore: promptStore
        )
    }

    private static func populateWithCannedData(modelContainer: ModelContainer) {
        print("PRE-CANNED DATA: Loading pre-canned data")
        if let sampleItems = Helpers.inputs() {
            let context = modelContainer.mainContext
            for item in sampleItems {
                debugPrint("Attempting to add \(item.text) with id \(item.id)")
                context.insert(item)
            }
            do {
                try context.save()
            } catch {
                fatalError("Unable to add item")
            }
        }
    }
}

enum DependencyContainerError: Error {
    case failedToLoadInputs
}

extension EnvironmentValues {
    @Entry var dependencies: DependencyContainer?
}
