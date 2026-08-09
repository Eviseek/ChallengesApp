//
//  HorizontalTappableItem.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 06.03.2026.
//

import SwiftUI

struct HorizontalTappableItem: View {

    var text: String
    var subtitle: String?
    var iconSystemName: String?
    var showArrow: Bool = true
    var action: () -> Void

    @ScaledMetric private var iconPillSize: CGFloat = 36
    @ScaledMetric private var iconPillFontSize: CGFloat = 16

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: Metrics.small) {
                if let iconName = iconSystemName {
                    iconPill(systemName: iconName)
                }
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                if showArrow {
                    Image(systemName: "chevron.forward")
                        .font(.caption)
                        .foregroundStyle(Color.Brand.labelSecondary)
                        .decorative()
                }
            }
            .padding(Metrics.small)
            .background(Color.Brand.cardBackground, in: RoundedRectangle(cornerRadius: Metrics.roundCornerRadius))
        }
        .buttonStyle(.plain)
        .contentShape(.rect)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: Metrics.extraMini) {
            Text(text)
                .font(.app(.subheadline, .semibold))
                .foregroundStyle(Color.Brand.label)
                .lineLimit(1)
            if let subtitle {
                Text(subtitle)
                    .font(.app(.caption))
                    .foregroundStyle(Color.Brand.labelSecondary)
                    .lineLimit(1)
            }
        }
    }

    // MARK: - Private Views

    private func iconPill(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: iconPillFontSize))
            .foregroundStyle(Color.Brand.onElectricGreenTint)
            .frame(width: iconPillSize, height: iconPillSize)
            .background(Color.Brand.electricGreenTint, in: RoundedRectangle(cornerRadius: Metrics.chipCornerRadius))
            .decorative()
    }
}
