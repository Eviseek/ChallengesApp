//
//  ChallengeDetailComponent.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 13.03.2026.
//

import SwiftUI

struct ChallengeDetailComponent<Model: ChallengeDetailComponentModelProtocol>: View {
    @State var model: Model
    @ScaledMetric private var iconSize: CGFloat = 36

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: Metrics.large) {
                headerSection
                ChallengeStakesCard(challenge: model.challenge)
                    .padding(.horizontal, Metrics.preferredPadding)
                leaderboardSection
            }
            .padding(.vertical, Metrics.medium)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await model.onAppear()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Metrics.extraSmall) {
            Text(model.challenge.displayDateRange)
                .font(.app(.caption2, .semibold))
                .foregroundStyle(Color.Brand.labelSecondary)
                .tracking(0.5)
                .textCase(.uppercase)
                .accessibilityLabel(model.challenge.accessibilityDateRange)
            Text(model.challenge.localizedTitle)
                .font(.app(.title2, .bold))
                .foregroundStyle(Color.Brand.label)
                .lineLimit(2)
                .accessibleHeader()
            if let description = model.challenge.localizedDescription {
                Text(description)
                    .font(.app(.subheadline))
                    .foregroundStyle(Color.Brand.labelSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Metrics.preferredPadding)
    }

    // MARK: - Leaderboard

    private var leaderboardSection: some View {
        StateView(
            state: model.screenState,
            retryAction: { Task { await model.retry() } },
            emptyStateView: { emptyStateView },
            content: { contentView }
        )
    }

    private var emptyStateView: some View {
        VStack(spacing: Metrics.small) {
            Image(systemName: "person.3")
                .font(.system(size: iconSize))
                .foregroundStyle(Color.Brand.labelSecondary)
                .decorative()
            Text("No participants yet")
                .font(.app(.subheadline, .semibold))
                .foregroundStyle(Color.Brand.labelSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(.top, Metrics.extraHuge)
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: Metrics.small) {
            Text("Leaderboard")
                .font(.app(.headline))
                .accessibleHeader()
                .padding(.horizontal, Metrics.preferredPadding)
            ForEach(model.leaderboard) { entry in
                LeaderboardRow(
                    rank: entry.rank,
                    participant: entry.participant,
                    goalType: model.challenge.goal.type
                )
                .padding(.horizontal, Metrics.preferredPadding)
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ChallengeDetailComponent(
            model: ChallengeDetailComponentModelMock()
        )
    }
}
#endif
