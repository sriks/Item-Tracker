//
//  ItemTrackerApp.swift
//  ItemTracker
//
//  Created by Srikanth on 17/10/2025.
//

import SwiftUI
import SwiftData

@main
struct ItemTrackerApp: App {
    private let dependencies: DependencyContainer

    init() {
        do {
            self.dependencies = try DependencyContainer.production()
        } catch {
            fatalError("Failed to initialize dependencies: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.dependencies, dependencies)
        }
    }
}
