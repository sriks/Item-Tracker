// JSONInputs.swift
// Defines Codable models for inputs.json and provides a helper to decode it.

import Foundation

// Top-level structure that matches the JSON shape: { "inputs": [ { "text": "..." }, ... ] }
public struct InputsContainer: Codable, Equatable {
    public let inputs: [TextContent]
}

public enum JSONInputsLoader {
    /// Decodes a Decodable type `T` from raw `Data`.
    public static func decode<T: Decodable>(from data: Data, as type: T.Type = T.self, using decoder: JSONDecoder = JSONDecoder()) throws -> T {
        return try decoder.decode(T.self, from: data)
    }

    /// Loads and decodes a Decodable type `T` from a resource in the given bundle.
    /// Defaults to `inputs.json` to preserve previous behavior.
    public static func loadFromBundle<T: Decodable>(/*as type: T.Type = T.self,*/
                                                    named fileName: String = "inputs",
                                                    withExtension ext: String = "json",
                                                    bundle: Bundle = .main,
                                                    using decoder: JSONDecoder = JSONDecoder()) throws -> T {
        guard let url = bundle.url(forResource: fileName, withExtension: ext) else {
            throw NSError(domain: "JSONInputsLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find \(fileName).\(ext) in bundle."])
        }
        let data = try Data(contentsOf: url)
        return try decode(from: data, as: T.self, using: decoder)
    }
}
