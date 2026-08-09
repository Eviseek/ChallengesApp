//
//  ChallengeStakesCard.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 22.06.2026.
//

import SwiftUI

struct ChallengeStakesCard: View {
    let challenge: Challenge

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.small) {
            ChallengeMetaRow(icon: "flag.fill", text: challenge.goal.description)
            if let prize = challenge.localizedPrize {
                ChallengeMetaRow(icon: "gift.fill", text: prize)
            }
        }
        .padding(Metrics.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.Brand.cardBackground, in: RoundedRectangle(cornerRadius: Metrics.roundCornerRadius))
        .accessibleCombined(label: combinedLabel)
    }

    private var combinedLabel: String {
        var parts = [LocalizedText.goal(challenge.goal.description)]
        if let prize = challenge.localizedPrize { parts.append(LocalizedText.prize(prize)) }
        return parts.joined(separator: ", ")
    }
}
