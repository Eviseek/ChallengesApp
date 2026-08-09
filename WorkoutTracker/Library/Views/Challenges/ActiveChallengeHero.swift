//
//  ActiveChallengeHero.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 22.06.2026.
//

import SwiftUI

struct ActiveChallengeHero: View {
    let challenge: Challenge

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.Brand.electricGreen
                .frame(height: 3)
                .decorative()
            content
        }
        .background(Color.Brand.cardBackground)
        .ignoresSafeArea(.container, edges: .horizontal)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: Metrics.extraSmall) {
            topRow
            Text(challenge.localizedTitle)
                .font(.app(.headline, .bold))
                .foregroundStyle(Color.Brand.label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
                .accessibleHeader()
            if let description = challenge.localizedDescription {
                Text(description)
                    .font(.app(.subheadline))
                    .foregroundStyle(Color.Brand.labelSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            infoRows
                .padding(.top, Metrics.extraMini)
        }
        .padding(Metrics.medium)
    }

    private var daysLeftBadge: some View {
        Text(challenge.daysLeftLabel)
            .font(.app(.caption, .bold))
            .foregroundStyle(Color.Brand.onElectricGreenTint)
            .padding(.horizontal, Metrics.mediumSmall)
            .padding(.vertical, Metrics.mini)
            .background(
                Color.Brand.electricGreenTint,
                in: RoundedRectangle(cornerRadius: Metrics.tileCornerRadius)
            )
    }

    private var topRow: some View {
        HStack(spacing: Metrics.small) {
            daysLeftBadge
            Spacer(minLength: 0)
            peopleLabel
        }
    }

    private var peopleLabel: some View {
        HStack(spacing: Metrics.mini) {
            Image(systemName: "person.2.fill")
            Text("\(challenge.participants.count)")
        }
        .font(.app(.caption, .semibold))
        .foregroundStyle(Color.Brand.labelSecondary)
        .accessibleCombined(label: LocalizedText.peopleJoined(challenge.participants.count))
    }

    private var infoRows: some View {
        VStack(alignment: .leading, spacing: Metrics.small) {
            infoRow(icon: "target", label: "Goal", value: challenge.goal.description)
            if let prize = challenge.localizedPrize {
                infoRow(icon: "gift.fill", label: "Prize", value: prize)
            }
        }
    }

    private func infoRow(icon: String, label: LocalizedStringKey, value: String) -> some View {
        VStack(alignment: .leading, spacing: Metrics.extraMini) {
            HStack(spacing: Metrics.mini) {
                Image(systemName: icon)
                    .decorative()
                Text(label)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            .font(.app(.caption2, .semibold))
            .foregroundStyle(Color.Brand.labelSecondary)

            Text(value)
                .font(.app(.subheadline, .semibold))
                .foregroundStyle(Color.Brand.label)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
#Preview {
    ActiveChallengeHero(challenge: .mock)
}
#endif
