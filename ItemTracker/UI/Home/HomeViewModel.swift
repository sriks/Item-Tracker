//
//  HomeViewModel.swift
//  ItemTracker
//
//  Created by Srikanth on 13/1/2026.
//

import Foundation
import Observation

@Observable @MainActor
class QueryViewModel {
    private var brain: ItemFindable
    var query = ""
    private(set) var answer: String? = "See your answers here."

    init(brain: ItemFindable) {
        self.brain = brain
    }
}

extension QueryViewModel {
    func runQuery() {
        Task { [weak self] in
            guard let self else { return }
            do {
                answer = try await brain.findItem(question: query)
            } catch {
                answer = "Could not find that item. \(error)"
            }
        }
    }
}
