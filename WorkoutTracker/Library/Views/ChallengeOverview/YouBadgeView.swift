//
//  YouBadgeView.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 24.04.2026.
//

import SwiftUI

struct YouBadgeView: View {
    var filled: Bool = false

    var body: some View {
        Text("You")
            .textCase(.uppercase)
            .font(.appFixed(size: 11, weight: .bold)) // Intentional fixed size — small decorative badge label.
            .foregroundStyle(Color.Brand.onElectricGreenTint)
            .padding(.horizontal, Metrics.extraSmall)
            .padding(.vertical, Metrics.extraMini)
            .background(
                filled ? Color.Brand.electricGreenTint : .clear,
                in: RoundedRectangle(cornerRadius: Metrics.extraMini)
            )
            .overlay {
                if !filled {
                    Capsule().stroke(Color.Brand.electricGreen, lineWidth: 1.5)
                }
            }
            .accessibilityLabel("You")
    }
}
