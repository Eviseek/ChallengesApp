//
//  ViewModifiers.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 20.05.2026.
//

import SwiftUI

// ViewModifier is required so the modifier is always present in the view tree regardless of isEnabled.
// A plain @ViewBuilder if/else would add or remove the modifier when isEnabled changes, causing SwiftUI
// to treat it as a structurally different view — destroying state and dismissing any presented modal.
// By always calling tabViewBottomAccessory and gating only the content inside, view identity stays stable.
// On iOS 26.1+ isEnabled: handles this natively; on 26.0 we keep the modifier applied with empty content.
struct TabViewBottomAccessoryModifier<AccessoryContent: View>: ViewModifier {
    let isEnabled: Bool
    @ViewBuilder let accessoryContent: () -> AccessoryContent

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.1, *) {
            content.tabViewBottomAccessory(isEnabled: isEnabled) {
                accessoryContent()
            }
        } else {
            content.tabViewBottomAccessory {
                if isEnabled {
                    accessoryContent()
                }
            }
        }
    }
}
