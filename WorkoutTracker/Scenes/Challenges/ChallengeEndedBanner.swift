//
//  ChallengeEndedBanner.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 24.04.2026.
//

import ConfettiSwiftUI
import SwiftUI

struct ChallengeEndedBanner: View {
    var challenge: Challenge
    var primaryAction: () -> Void
    var secondaryAction: () -> Void

    @State private var shootConfetti: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.small) {
            headerRow
            topThreeView
            Button(action: primaryAction) {
                Text("Show All Results")
                    .font(.app(.caption, .semibold))
                    .foregroundStyle(Color.Brand.onElectricGreen)
                    .padding(.horizontal, Metrics.medium)
                    .padding(.vertical, Metrics.extraSmall)
                    .background(Color.Brand.electricGreen, in: Capsule())
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(Metrics.medium)
        .background(Color.Brand.cardBackground, in: RoundedRectangle(cornerRadius: Metrics.roundCornerRadius))
        .onAppear {
            shootConfetti = true
        }
    }

    private var headerRow: some View {
        HStack(alignment: .top, spacing: Metrics.small) {
            VStack(alignment: .leading, spacing: Metrics.extraMini) {
                Text("Challenge Ended!")
                    .font(.app(.headline, .bold))
                    .foregroundStyle(Color.Brand.label)
                    .confettiCannon(
                        trigger: $shootConfetti,
                        confettiSize: 10,
                        repetitions: 2,
                        repetitionInterval: 0.5,
                        hapticFeedback: true
                    )
                Text(challenge.localizedTitle)
                    .font(.app(.subheadline, .medium))
                    .foregroundStyle(Color.Brand.labelSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: secondaryAction) {
                Image(systemName: "xmark")
                    .font(.app(.caption, .bold))
                    .foregroundStyle(Color.Brand.labelSecondary)
                    .padding(Metrics.extraSmall)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")
        }
    }

    @ViewBuilder private var topThreeView: some View {
        let topThree = challenge.participants.ranked(onlyScoring: false).prefix(3)
        if !topThree.isEmpty {
            VStack(spacing: Metrics.extraMini) {
                ForEach(topThree) { entry in
                    HStack(spacing: Metrics.extraSmall) {
                        Text("\(entry.rank)")
                            .font(.app(.caption, .bold))
                            .foregroundStyle(entry.rank == 1 ? Color.Brand.electricGreen : Color.Brand.labelSecondary)
                            .frame(width: Metrics.medium, alignment: .center)
                        Text(entry.participant.isCurrentUser ? "You" : entry.participant.displayName)
                            .font(.app(.caption, .semibold))
                            .foregroundStyle(Color.Brand.label)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.vertical, Metrics.extraMini)
        }
    }
}
