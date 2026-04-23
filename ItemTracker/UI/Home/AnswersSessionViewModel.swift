//
//  AnswersSessionViewModel.swift
//  ItemTracker
//

import Foundation
import Observation

/// The single observable driving the answers UI.
///
/// Owns the AI brain, accumulates query results (success or error), and exposes
/// derived presentation state. `AnswersSheet` and `AskScreen` depend only on this —
/// there is no separate QueryViewModel.
@Observable @MainActor
final class AnswersSessionViewModel {
    // MARK: - Nested types

    enum AnswerResult {
        case success(String)
        case error(String) // user-friendly message, not a raw Error
    }

    struct Answer: Identifiable {
        let id = UUID()
        let question: String
        let result: AnswerResult
    }

    // MARK: - State

    private let brain: ItemFindable
    private(set) var answers: [Answer] = []
    private(set) var isQuerying = false

    /// Derived — true whenever there is at least one answer to show.
    /// No separate stored Bool needed; `reset()` clearing `answers` makes this false automatically.
    var isPresented: Bool {
        !answers.isEmpty
    }

    // MARK: - Init

    init(brain: ItemFindable) {
        self.brain = brain
    }

    // MARK: - Actions

    func ask(_ question: String) async {
        guard !question.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isQuerying = true
        defer { isQuerying = false }
        do {
            let text = try await brain.findItem(question: question) ?? "No answer found."
            answers.append(Answer(question: question, result: .success(text)))
        } catch {
            answers.append(Answer(question: question, result: .error(error.localizedDescription)))
        }
    }

    /// Clears all accumulated answers. `isPresented` becomes false automatically.
    func reset() {
        answers.removeAll()
    }
}

// MARK: - Preview helpers

extension AnswersSessionViewModel {
    /// Returns a preview-ready session pre-seeded with `count` sample answers.
    static func preview(answers count: Int = 1) -> AnswersSessionViewModel {
        let session = AnswersSessionViewModel(brain: (try! DependencyContainer.preview()).itemFinder)
        let pool: [Answer] = [
            .init(
                question: "Where are the macbook chargers?",
                result: .success("Macbook chargers are stored in the library, 3rd drawer from the top.")
            ),
            .init(
                question: "Where did I put the scissors?",
                result: .success("The scissors are on the kitchen counter, next to the coffee maker.")
            ),
            .init(
                question: "What's in the storage room?",
                result: .success("Toilet rolls (2nd row), cleaning supplies, spare lightbulbs in the top box.")
            ),
            .init(
                question: "Where is the blue USB cable?",
                result: .error("Could not find any matching item.")
            ),
        ]
        session.answers = Array(pool.prefix(count))
        return session
    }
}
