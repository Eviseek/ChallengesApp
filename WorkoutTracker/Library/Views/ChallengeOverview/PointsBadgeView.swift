//
//  PointsBadgeView.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 24.04.2026.
//

import SwiftUI

struct PointsBadgeView: View {
    let value: Double
    var background: Color = Color.Brand.electricGreen
    var foreground: Color = Color.Brand.onElectricGreen

    var body: some View {
        HStack(spacing: Metrics.mini) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 10, weight: .bold)) // Intentional fixed size — small decorative badge icon.
                .decorative()
            Text(LocalizedText.shortPoints(Int(value)))
                .font(.appFixed(size: 12, weight: .bold)) // Intentional fixed size — small decorative badge label.
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, Metrics.extraSmall)
        .padding(.vertical, Metrics.mini)
        .background(Capsule().fill(background))
        .accessibleCombined(label: LocalizedText.points(Int(value)))
    }
}
