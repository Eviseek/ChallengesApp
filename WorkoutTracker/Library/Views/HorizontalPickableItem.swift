//
//  HorizontalPickableItem.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 06.03.2026.
//

import SwiftUI

struct HorizontalPickableItem: View {

    var text: String
    var subtitle: String?
    var isSelected: Bool = false
    var mainAction: () -> Void
    var infoAction: () -> Void

    @ScaledMetric private var infoIconSize: CGFloat = 20

    var body: some View {
        Button {
            mainAction()
        } label: {
            buttonLabel
        }
        .buttonStyle(.plain)
        .contentShape(.rect)
        .padding(Metrics.small)
        .background(Color.Brand.cardBackground, in: RoundedRectangle(cornerRadius: Metrics.roundCornerRadius))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityAction(named: Text("More information")) { infoAction() }
    }

    private var buttonLabel: some View {
        HStack(spacing: Metrics.small) {
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
            Image(systemName: "info.circle.fill")
                .font(.system(size: infoIconSize))
                .foregroundStyle(Color.Brand.electricGreen)
                .decorative()
                .onTapGesture {
                    infoAction()
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
