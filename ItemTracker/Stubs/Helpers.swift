//
//  Helpers.swift
//  ItemTracker
//
//  Created by Srikanth on 17/10/2025.
//

import Foundation

enum Helpers {}

extension Helpers {
    /// Loads items from JSON file for seeding data.
    /// Creates Item objects with incremental timestamps (1 second apart).
    static func inputs(fileName: String = "inputs") -> [Item]? {
        do {
            let container: InputsContainer = try JSONInputsLoader.loadFromBundle(named: fileName)
            let baseDate = Date()

            return container.inputs.enumerated().map { index, jsonItem in
                let item = Item(text: jsonItem.text)
                item.timestamp = baseDate.addingTimeInterval(TimeInterval(index))
                item.lastModified = item.timestamp
                return item
            }
        } catch {
            print(error)
            return nil
        }
    }
}
