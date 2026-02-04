//
//  Helpers.swift
//  ItemTracker
//
//  Created by Srikanth on 17/10/2025.
//

import Foundation

enum Helpers {}

extension Helpers {
    /// Loads text content from JSON file for seeding data
    static func inputs(fileName: String = "inputs") -> [TextContent]? {
        do {
            let container: InputsContainer = try JSONInputsLoader.loadFromBundle(named: fileName)
            return container.inputs
        } catch {
            print(error)
            return nil
        }
    }
}
