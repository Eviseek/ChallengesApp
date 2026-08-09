//
//  SetDisplayField.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 16.04.2026.
//

import SwiftUI

struct SetDisplayField: View {
    let title: LocalizedStringKey
    let value: String?
    var calculateWidth: Bool = true

    var body: some View {
        SetFieldContainer(title: title, calculateWidth: calculateWidth) {
            Text(value ?? "")
                // Prevents collapse to zero height when value is nil; UIFont tracks Dynamic Type.
                .frame(minHeight: UIFont.preferredFont(forTextStyle: .body).lineHeight)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value ?? String(localized: "Empty"))
    }
}
