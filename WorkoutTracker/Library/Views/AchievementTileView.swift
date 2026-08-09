//
//  AchievementTileView.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 29.04.2026.
//

import SwiftUI

struct AchievementTileView: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    var accessibilityLabel: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.extraSmall) {
            iconView
                .decorative()
            Text(value)
                .font(.Archivo.stat)
                .foregroundStyle(Color.Brand.label)
            Text(label)
                .font(.app(.caption, .semibold))
                .foregroundStyle(Color.Brand.labelSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Metrics.medium)
        .background(Color.Brand.cardBackground, in: RoundedRectangle(cornerRadius: Metrics.roundCornerRadius))
        .accessibleCombined(label: accessibilityLabel ?? LocalizedText.stat(value: value, label: label))
    }

    // Intentional fixed size — decorative icon in stat tile.
    private var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Metrics.tileCornerRadius)
                .fill(iconColor.opacity(0.12))
                .frame(width: Metrics.iconTileSize, height: Metrics.iconTileSize)
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(iconColor)
        }
    }
}
