//
//  ChallengeMetaRow.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 17.07.2026.
//

import SwiftUI

/// Icon + caption row shared by the challenge cards (goal, participants, prize).
struct ChallengeMetaRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Metrics.extraSmall) {
            Image(systemName: icon)
                .foregroundStyle(Color.Brand.labelSecondary)
                .frame(width: Metrics.medium)
                .decorative()
            Text(text)
                .foregroundStyle(Color.Brand.labelSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.app(.caption))
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: Metrics.extraSmall) {
        ChallengeMetaRow(icon: "flag.fill", text: "Lift 10,000 kg total")
        ChallengeMetaRow(icon: "person.2.fill", text: "8 participants")
        ChallengeMetaRow(icon: "gift.fill", text: "Winner buys coffee")
    }
    .padding()
}
#endif
