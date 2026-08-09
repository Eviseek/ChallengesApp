//
//  String+Extensions.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 08.04.2026.
//

import Foundation

extension String {
    /// Converts localized decimal input to a `Double` by normalizing "," to ".".
    var normalized: Double {
        let normalized = self
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(normalized) ?? 0
    }
}

extension String {
    private static let nameFormatter = PersonNameComponentsFormatter()

    // PersonNameComponentsFormatter is used only for parsing a raw string into name components, since PersonNameComponents.FormatStyle has no parsing capability.
    // Abbreviation is then handled by FormatStyle to avoid NSPersonNameComponentsFormatter's known limitation of naively taking the first letter of each component.
    var abbreviatedName: String {
        guard let components = Self.nameFormatter.personNameComponents(from: self) else { return "" }
        return components.formatted(.name(style: .abbreviated))
    }
}
