//
//  LeaderboardRow.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 11.06.2026.
//

import SwiftUI

struct LeaderboardRow: View {
    let rank: Int
    let participant: Participant
    let goalType: Goal.GoalType

    private var isLeader: Bool {
        rank == 1
    }

    var body: some View {
        HStack(spacing: Metrics.extraSmall) {
            content
        }
        .padding(.horizontal, Metrics.small)
        .padding(.vertical, Metrics.mediumSmall)
        .background(
            isLeader ? Color.Brand.electricGreen : Color.Brand.cardBackground,
            in: RoundedRectangle(cornerRadius: Metrics.chipCornerRadius)
        )
        .overlay {
            if participant.isCurrentUser && !isLeader {
                RoundedRectangle(cornerRadius: Metrics.chipCornerRadius)
                    .stroke(Color.Brand.electricGreen, lineWidth: 1.5)
            }
        }
        .accessibleCombined(label: LocalizedText.rank(rank, name: participant.displayName, value: goalType.formattedParticipantValue(participant.value)))
    }

    @ViewBuilder private var content: some View {
        Text("\(rank)")
            .font(.app(.caption, .bold))
            .foregroundStyle(isLeader ? Color.Brand.onElectricGreen : Color.secondary)
            .frame(width: 16, alignment: .center)
        participantNameView
        Spacer(minLength: 0)
        Text(goalType.formattedParticipantValue(participant.value))
            .font(.app(.caption, .semibold))
            .foregroundStyle(isLeader ? Color.Brand.onElectricGreen : Color.secondary)
    }

    private var participantNameView: some View {
        HStack(spacing: Metrics.mini) {
            Text(participant.displayName)
                .font(.app(.subheadline, .semibold))
                .foregroundStyle(isLeader ? Color.Brand.onElectricGreen : Color.primary)
            if participant.isCurrentUser && !isLeader {
                YouBadgeView(filled: true)
            }
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: Metrics.small) {
        LeaderboardRow(
            rank: 1,
            participant: Participant(id: "p1", displayName: "Lucas Hill", value: 120, contributions: [], isCurrentUser: false),
            goalType: .totalVolume(unit: .kg)
        )
        LeaderboardRow(
            rank: 5,
            participant: Participant(id: "p5", displayName: "Eva Chlpikova", value: 87, contributions: [], isCurrentUser: true),
            goalType: .totalVolume(unit: .kg)
        )
    }
    .padding()
}
#endif
