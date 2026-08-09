//
//  ChallengeCard.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 22.06.2026.
//

import SwiftUI

struct ChallengeCard: View {
    let challenge: Challenge
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Metrics.extraSmall) {
                header
                content
                // Participants are pre-sorted by value descending by ChallengeService — first is the leader.
                if let winner = challenge.participants.first {
                    winnerStrip(winner, goalType: challenge.goal.type)
                        .padding(.top, Metrics.extraSmall)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Metrics.medium)
            .background(Color.Brand.cardBackground, in: RoundedRectangle(cornerRadius: Metrics.cardCornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(challenge.accessibilityLabelEnded)
    }

    @ViewBuilder private var header: some View {
        Text(challenge.endedEyebrow)
            .font(.app(.caption2, .semibold))
            .foregroundStyle(Color.Brand.labelSecondary)
            .tracking(0.5)
            .textCase(.uppercase)
        Divider()
            .padding(.bottom, Metrics.extraSmall)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: Metrics.mini) {
            Text(challenge.localizedTitle)
                .font(.app(.subheadline, .bold))
                .foregroundStyle(Color.Brand.label)
                .lineLimit(2)
            cardMeta
        }
    }

    private var cardMeta: some View {
        VStack(alignment: .leading, spacing: Metrics.extraSmall) {
            ChallengeMetaRow(icon: "flag.fill", text: challenge.goal.description)
            if !challenge.participants.isEmpty {
                ChallengeMetaRow(
                    icon: "person.2.fill",
                    text: LocalizedText.participants(challenge.participants.count)
                )
            }
            if let prize = challenge.localizedPrize {
                ChallengeMetaRow(icon: "gift.fill", text: prize)
            }
        }
    }

    private func winnerStrip(_ winner: Participant, goalType: Goal.GoalType) -> some View {
        HStack(spacing: Metrics.extraSmall) {
            Image(systemName: "crown.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.Brand.onElectricGreenTint)
                .decorative()
            Text(winner.isCurrentUser ? String(localized: "You") : winner.displayName)
                .font(.app(.caption, .bold))
                .foregroundStyle(Color.Brand.onElectricGreenTint)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(goalType.formattedParticipantValue(winner.value))
                .font(.app(.caption, .semibold))
                .foregroundStyle(Color.Brand.onElectricGreenTint)
        }
        .padding(.horizontal, Metrics.mediumSmall)
        .padding(.vertical, Metrics.extraSmall)
        .background(Color.Brand.electricGreenTint, in: RoundedRectangle(cornerRadius: Metrics.tileCornerRadius))
    }
}

#if DEBUG
#Preview {
    ChallengeCard(challenge: .mockFinished) {}
        .padding()
}
#endif
