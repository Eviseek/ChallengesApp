//
//  LocalizedStringDB.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 16.07.2026.
//

import Foundation

// Firestore representation of a localized string: encodes/decodes the language map flat ({ "en": ..., "cs": ... }).
// Kept separate from LocalizedString because SwiftData's composite coder is incompatible with this flat single-value encoding.
nonisolated struct LocalizedStringDB: Hashable, Equatable, Sendable, Codable {
    var values: [String: String]

    init(_ values: [String: String]) {
        self.values = values
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        values = try container.decode([String: String].self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(values)
    }

    var localizedString: LocalizedString {
        LocalizedString(values)
    }
}
