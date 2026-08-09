//
//  LocalizedString.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 15.07.2026.
//

import Foundation

// Per-language text stored as a { languageCode: value } map, resolved to the active language at display time.
// Uses synthesized Codable (encodes as { "values": { ... } }) so SwiftData can persist it as a composite attribute.
// For Firestore, use LocalizedStringDB, which encodes the map flat and tolerates a legacy bare string.
nonisolated struct LocalizedString: Hashable, Equatable, Sendable, Codable {
    var values: [String: String]

    init(_ values: [String: String]) {
        self.values = values
    }

    var localized: String {
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        return values[code] ?? values["en"] ?? values.first?.value ?? ""
    }
}
