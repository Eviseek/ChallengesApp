//
//  OthersRowView.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 24.04.2026.
//

import SwiftUI

struct OthersRowView: View {
    let rank: Int
    let participant: Participant

    @State private var rankWidth: CGFloat = 0

    var body: some View {
        HStack(spacing: Metrics.small) {
            rankTextView
            avatarView
            participantNameView
            pointsView
        }
        .padding(.horizontal, Metrics.small)
        .padding(.vertical, Metrics.mediumSmall)
        .accessibleCombined(label: LocalizedText.rank(rank, name: participant.isCurrentUser ? String(localized: "You") : participant.displayName, value: LocalizedText.points(Int(participant.value))))
        .background { background }
    }

    private var avatarView: some View {
        AvatarView(name: participant.displayName, size: Metrics.compactAvatarSize, isCurrentUser: participant.isCurrentUser)
    }

    private var participantNameView: some View {
        HStack(spacing: Metrics.extraSmall) {
            Text(participant.displayName)
                .font(.app(.subheadline, .semibold))
                .lineLimit(1)
                .foregroundStyle(participant.isCurrentUser ? Color.Brand.electricGreen : Color.Brand.label)
            if participant.isCurrentUser {
                YouBadgeView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rankTextView: some View {
        ZStack {
            Text(verbatim: "XX")
                .opacity(0)
                .font(.app(.headline))
                .readSize { rankWidth = $0.width }

            Text("\(rank)")
                .font(.app(.headline))
                .foregroundStyle(Color.Brand.labelSecondary)
                .frame(width: rankWidth, alignment: .leading)
        }
    }

    @ViewBuilder private var pointsView: some View {
        if participant.isCurrentUser {
            PointsBadgeView(value: participant.value)
        } else {
            Text("\(Int(participant.value))")
                .font(.app(.subheadline, .bold))
                .foregroundStyle(Color.Brand.labelSecondary)
        }
    }

    @ViewBuilder private var background: some View {
        if participant.isCurrentUser {
            RoundedRectangle(cornerRadius: Metrics.roundCornerRadius)
                .fill(Color.Brand.cardBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: Metrics.roundCornerRadius)
                        .stroke(Color.Brand.electricGreen, lineWidth: 1.5)
                }
        }
    }
}
