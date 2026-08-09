//
//  SetRowView.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 10.03.2026.
//

import SwiftUI

struct SetRowView<Fields: View>: View {

    let setNumber: Int
    let isFilledOut: Bool
    var onDelete: (() -> Void)?
    @ViewBuilder let fields: () -> Fields

    @ScaledMetric(relativeTo: .caption2)
    private var completionBadgeSize: CGFloat = 12

    var body: some View {
        HStack(spacing: Metrics.small) {
            setNumberBadge
            fields()
            if let onDelete {
                deleteButton(action: onDelete)
            }
        }
        .padding(.horizontal, Metrics.small)
        .padding(.vertical, Metrics.mediumSmall)
        .background(Color.Brand.cardBackgroundTertiary, in: RoundedRectangle(cornerRadius: Metrics.roundCornerRadius))
    }

    // MARK: - Private Views

    private var setNumberBadge: some View {
        Text(setNumber.description)
            .foregroundStyle(Color.Brand.label)
            .font(.app(.footnote))
            .padding(Metrics.extraSmall)
            .background(Circle().fill(Color.Brand.grayBorder))
            // Completion marker overlaps the badge's top-right corner; shown only once the set is done.
            .overlay(alignment: .topTrailing) {
                if isFilledOut {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: completionBadgeSize))
                        .foregroundStyle(Color.Brand.electricGreen)
                        .background(Circle().fill(Color.Brand.cardBackgroundTertiary))
                        .offset(x: Metrics.extraMini, y: Metrics.extraMini / 2)
                        .decorative()
                }
            }
            .accessibilityLabel(LocalizedText.set(setNumber, isComplete: isFilledOut))
    }

    private func deleteButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "trash")
                .font(.app(.footnote))
                .foregroundStyle(Color.Brand.destructive)
                .padding(Metrics.extraSmall)
                .background(Circle().fill(Color.Brand.grayBorder))
                .frame(width: Metrics.minTouchTargetSize, height: Metrics.minTouchTargetSize)
                .contentShape(.rect)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(Text("Delete Set"))
    }
}

#if DEBUG
#Preview {
    VStack(spacing: Metrics.small) {
        SetRowView(setNumber: 1, isFilledOut: true) {
            Text(verbatim: "Fields")
        }
        SetRowView(setNumber: 2, isFilledOut: false) {
            Text(verbatim: "Fields")
        }
    }
    .padding()
}
#endif
