//
//  PodiumSlotView.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 24.04.2026.
//

import SwiftUI

struct PodiumSlotView: View {
    let participant: Participant
    let rank: Int
    let avatarSize: CGFloat

    // Ring and border are determined by rank, not passed from outside.
    private var ringColor: Color { rank == 1 ? Color.Brand.electricGreen : Color.Brand.futuristicGrey }
    private var borderWidth: CGFloat { rank == 1 ? 3.5 : 2.5 }

    private var rankIconName: String { rank == 1 ? "crown.fill" : "medal.fill" }

    private var rankIconColor: Color {
        switch rank {
        case 1:
            Color.Brand.electricGreen
        case 2:
            Color.Brand.label
        default:
            Color.Brand.labelSecondary
        }
    }

    var body: some View {
        VStack(spacing: Metrics.extraSmall) {
            Image(systemName: rankIconName)
                .font(.system(size: rank == 1 ? 28 : 20)) // Intentional fixed size — decorative rank icon.
                .foregroundStyle(rankIconColor)
                .decorative()
            avatarView
            Text(participant.displayName)
                .font(.appFixed(size: 13, weight: .semibold)) // Intentional fixed size — avatar name label inside hero.
                .foregroundStyle(Color.Brand.label)
                .lineLimit(1)
                .frame(maxWidth: avatarSize + 8)
                .multilineTextAlignment(.center)
            if participant.isCurrentUser {
                YouBadgeView()
            }
            pointsView
        }
        .frame(maxWidth: .infinity)
        .offset(y: rank == 1 ? -16 : 0)
        .accessibleCombined(label: LocalizedText.rank(rank, name: participant.isCurrentUser ? String(localized: "You") : participant.displayName, value: LocalizedText.points(Int(participant.value))))
    }

    private var avatarView: some View {
        AvatarView(name: participant.displayName, size: avatarSize, isCurrentUser: participant.isCurrentUser)
            .overlay {
                Circle().stroke(ringColor, lineWidth: borderWidth)
            }
    }

    @ViewBuilder private var pointsView: some View {
        if rank == 1 {
            PointsBadgeView(value: participant.value)
        } else {
            PointsBadgeView(
                value: participant.value,
                background: Color.Brand.cardBackground,
                foreground: Color.Brand.label
            )
        }
    }
}
