//
//  ChallengesComponent.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 12.03.2026.
//

import FuturedArchitecture
import SwiftUI

struct ChallengesComponent<Model: ChallengesComponentModelProtocol>: View {
    enum Tab: String, CaseIterable {
        case active = "Active"
        case past = "Past"

        // Literal keys so the segment titles are extracted into the string catalog and localized.
        var title: LocalizedStringKey {
            switch self {
            case .active:
                "Active"
            case .past:
                "Past"
            }
        }
    }

    @State var model: Model
    @State private var selectedTab: Tab = .active
    @ScaledMetric private var iconSize: CGFloat = 40

    var body: some View {
        @Bindable var model = model
        StateView(
            state: model.screenState,
            retryAction: { Task { await model.retry() } },
            emptyStateView: { EmptyView() },
            content: { mainView }
        )
        .task {
            await model.onAppear()
        }
        .defaultAlert(model: $model.alertModel)
        .navigationTitle("Challenges")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var mainView: some View {
        VStack(spacing: 0) {
            Picker("Challenge filter", selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Metrics.preferredPadding)
            .padding(.bottom, Metrics.preferredPadding)

            switch selectedTab {
            case .active:
                activeTabView
            case .past:
                pastTabView
            }
        }
    }

    // MARK: - Active Tab

    private var activeTabView: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                if case let .challengeJustEnded(challenge) = model.state {
                    ChallengeEndedBanner(
                        challenge: challenge,
                        primaryAction: { model.openChallengeOverview(challenge) },
                        secondaryAction: { model.dismissChallengeEnded() }
                    )
                    .padding(.horizontal, Metrics.medium)
                    .padding(.bottom, Metrics.medium)
                }
                if let challenge = model.activeChallenge {
                    VStack(spacing: 0) {
                        ActiveChallengeHero(challenge: challenge)
                        leaderboardSection(challenge)
                    }
                } else {
                    noChallengeView
                }
            }
        }
        .scrollIndicators(.hidden)
        .animation(.appStateChange, value: model.state)
        .refreshable {
            await model.syncChallenges()
        }
    }

    private var noChallengeView: some View {
        VStack(spacing: Metrics.small) {
            Image(systemName: "trophy")
                .font(.system(size: iconSize))
                .foregroundStyle(Color.Brand.labelSecondary)
                .decorative()
            Text("No active challenge")
                .font(.app(.headline))
                .accessibleHeader()
            Text("Check back later — challenges are set up by your group admin.")
                .font(.app(.subheadline))
                .foregroundStyle(Color.Brand.labelSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Metrics.extraHuge)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    // MARK: - Leaderboard

    private func leaderboardSection(_ challenge: Challenge) -> some View {
        VStack(alignment: .leading, spacing: Metrics.extraSmall) {
            Text("Leaderboard")
                .font(.app(.headline))
                .accessibleHeader()
                .padding(.horizontal, Metrics.medium)
            if model.leaderboard.isEmpty {
                leaderboardEmptyView
            } else {
                ForEach(model.leaderboard) { entry in
                    LeaderboardRow(
                        rank: entry.rank,
                        participant: entry.participant,
                        goalType: challenge.goal.type
                    )
                    .padding(.horizontal, Metrics.medium)
                }
            }
        }
        .padding(.top, Metrics.large)
        .padding(.bottom, Metrics.large)
    }

    private var leaderboardEmptyView: some View {
        VStack(spacing: Metrics.small) {
            Image(systemName: "person.3")
                .font(.system(size: iconSize))
                .foregroundStyle(Color.Brand.labelSecondary)
                .decorative()
            Text("No participants yet")
                .font(.app(.subheadline, .semibold))
                .foregroundStyle(Color.Brand.labelSecondary)
            Text("Scores will appear here once people join the challenge.")
                .font(.app(.footnote))
                .foregroundStyle(Color.Brand.labelSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Metrics.extraHuge)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Metrics.large)
    }

    // MARK: - Past Tab

    private var pastTabView: some View {
        ScrollView(.vertical) {
            if model.pastChallenges.isEmpty {
                VStack(spacing: Metrics.small) {
                    Image(systemName: "clock")
                        .font(.system(size: iconSize))
                        .foregroundStyle(Color.Brand.labelSecondary)
                        .decorative()
                    Text("No past challenges")
                        .font(.app(.headline))
                        .accessibleHeader()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                VStack(spacing: Metrics.extraSmall) {
                    ForEach(model.pastChallenges, id: \.id) { challenge in
                        ChallengeCard(challenge: challenge) {
                            model.openChallengeDetail(challenge)
                        }
                    }
                }
                .padding(.horizontal, Metrics.medium)
                .padding(.vertical, Metrics.extraSmall)
            }
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await model.syncChallenges()
        }
    }
}

#if DEBUG
#Preview {
    ChallengesComponent(
        model: ActiveChallengeComponentModelMock()
    )
}
#endif
