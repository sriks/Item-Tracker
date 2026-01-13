//
//  Helpers.swift
//  ItemTracker
//
//  Created by Srikanth on 17/10/2025.
//

import Foundation

enum Helpers {}

extension Helpers {
    static func inputs(fileName: String = "inputs") -> [InputItem]? {
        do {
            let container: InputsContainer = try JSONInputsLoader.loadFromBundle(named: fileName)
            return container.inputs
        } catch {
            print(error)
            return nil
        }
    }
    
    static func prefilWithInputs(fileName: String = "inputs") -> ReasoningBrain? {
        let inputs = Self.inputs(fileName: fileName)!
        let brain = ReasoningBrain(notes: inputs, instructions: nil)
        return brain
    }
}
