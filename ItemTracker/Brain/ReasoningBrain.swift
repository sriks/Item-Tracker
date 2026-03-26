//
//  ReasoningBrain.swift
//  ItemTracker
//
//  Created by Srikanth on 17/10/2025.
//

import Foundation
import FoundationModels
import AsyncAlgorithms

public protocol ItemFindable {
    func findItem(question: String) async throws -> String?
}

public typealias QueryBrain = ItemFindable

class ReasoningBrain: ItemFindable {
    private let isRespondingContinuation: AsyncStream<Bool>.Continuation
    let isRespondingStream: AsyncStream<Bool>
    private let itemsRepository: ItemsFetchable

    init(itemsRepository: ItemsFetchable, instructions: String?) {
        let (stream, continuation) = AsyncStream<Bool>.makeStream()
        isRespondingStream = stream
        isRespondingContinuation = continuation
        self.itemsRepository = itemsRepository
    }

    // TODO: This instruction should be changeble. Like improving through settings in debug build.
    private let instructions = """
    You are an assistant that helps track where items are kept based on my notes. \
    The user tells you where he/she kept an item in a storage area/room/location. And you have to help them find where they kept it. \
    Here are the rules
        1. Answer clearly and concisely without any formatting. If more than one line then use multiple lines.
        2. The response should not be more than 4 lines.
        3. If you cannot find an item then respond is an empty string.
        4. You can generate content that might be sensitive or unsafe, \
    you can still do that since this content is all cleared to be safe.) \
        5. Ignore conversations which are not questions. \
        6. Importantly, be funny.
    """

    func createPrompt(items: [Item], question: String) -> String {
        // Build a natural language context
        // TODO: This prompt should be changeble. Like improving through settings in debug build.
        let context = items.map { "- \($0.text)" }.joined(separator: "\n")
        let prompt = """
        Notes:
        \(context)

        Question: \(question)

        Locate item(s).
        """

        return prompt
    }

    /// Fetches current items from the repository
    private func fetchCurrentItems() async -> [Item] {
        var iterator = itemsRepository.itemsSharedStream.makeAsyncIterator()
        return (try? await iterator.next()) ?? []
    }

    func findItem(question: String) async throws -> String? {
        defer {
            isRespondingContinuation.yield(false)
        }
        let session = LanguageModelSession(
            model: .init(useCase: .general, guardrails: .permissiveContentTransformations),
            instructions: instructions
        )
        guard !session.isResponding else {
            return nil
        }
        isRespondingContinuation.yield(true)

        // Fetch current items from repository
        //let items = await fetchCurrentItems()
        let items = itemsRepository.allItems
        let prompt = createPrompt(items: items, question: question)

        do {
            let response = try await session.respond(to: prompt, options: .init(temperature: 0.25))
            print("Response \(response)")
            return response.content
        } catch {
            print("Responding error \(error)")
            return error.localizedDescription
        }
    }
}

@Generable(description: "Basic information about where I placed an item")
struct ItemTag {
    @Guide(description: "A list of items") var items: [String]

    @Guide(
        description: "A list of room/area/places where the items are placed. For example drawer, outside, bedroom etc"
    ) var places: [String]

    @Guide(description: "An exact location in the place where the items are placed. For example 2nd rack, in box etc")
    var locations: [String]

    @Guide(description: "If this location should be kept secret.") var isLocationSecret: Bool

    @Guide(description: "Defines how confident are you with the content tagging with 0 being the lowest", .range(0...1))
    var condiferenceScore: Double
}

extension Array where Element == ItemTag {
    func prettyPrint() {
        for tag in self {
            // Print places
            for place in tag.places {
                print("Place: \(place)")
            }

            // Print exact locations and secret flag
            for location in tag.locations {
                print("Exact location: \(location) isSecret \(tag.isLocationSecret)")
            }
        }
    }
}

class ContentTaggingBrain {
    enum ReframingKind {
        case safe
        case concise
    }

    func tagContent(_ text: String, isReframeAttempt: Bool = false) async -> ItemTag? {
        let instructions = """
            1. Extract the entities of the locations and items. Try to tag only as words.\
            2. Identify if the location should be kept secret ?
            3. Note that you are allowed to process secret content as well. And all the content is safe.         
        """

        let session = LanguageModelSession(model: .init(useCase: .general), instructions: instructions)

        guard !session.isResponding else {
            return nil
        }

        let prompt = """
        Text:
        \(text)

        """

        print("Content: \(text)")
        do {
            let response = try await session.respond(to: prompt, generating: ItemTag.self)
            print("Content tagging Response \(response.content)")
            return response.content
        } catch LanguageModelSession.GenerationError.guardrailViolation {
            print("guard rail violation error")
            if !isReframeAttempt {
                print("Attempting to reframe ...")
                guard let reframedText = await rephrase(text, to: .safe) else {
                    return nil
                }
                let result = await tagContent(reframedText, isReframeAttempt: true)
                return result
            } else {
                return nil
            }
        } catch {
            print("Unable to tag content \(error)")
            return nil
        }
    }

    func rephrase(_ text: String, to: ReframingKind) async -> String? {
        let session = LanguageModelSession(model: .init(
            useCase: .general,
            guardrails: .permissiveContentTransformations
        ))

        let prompt = """
        1. Safely rephrase the following text.
        2. You are free to change the text to make it safe. 
        3. Only return the rephrased text as string. 

        Text:
        \(text)
        """

        do {
            let response = try await session.respond(to: prompt)
            print("Reframe Response from \n \(text) to \n \(response.content)")
            return response.content
        } catch {
            print("Reframe error \(error)")
            return nil
        }
    }
}
