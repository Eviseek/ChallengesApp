//
//  ChallengeOverviewComponent.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 23.04.2026.
//

import SwiftUI

struct ChallengeOverviewComponent<Model: ChallengeOverviewComponentModelProtocol>: View {
    @State var model: Model
    @ScaledMetric private var avatarSizeFirst: CGFloat = 90
    @ScaledMetric private var avatarSizeOther: CGFloat = 70

    var body: some View {
        StateView(
            state: model.screenState,
            retryAction: { Task { await model.retry() } },
            emptyStateView: { EmptyView() },
            content: { contentScrollView }
        )
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task { await model.onAppear() }
    }

    private var contentScrollView: some View {
        ScrollView {
            populatedContent
        }
        .scrollIndicators(.hidden)
    }

    private var populatedContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            winnersView(participants: model.challenge.participants)
                .padding(.top, Metrics.extraLarge)
                .padding(.bottom, Metrics.extraLarge)
            Divider()
                .padding(.horizontal, Metrics.preferredPadding)
            othersSection
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Metrics.extraSmall) {
            Text(String(localized: "Final results"))
                .font(.caption.weight(.heavy))
                .fontDesign(.monospaced)
                .tracking(2)
                .foregroundStyle(Color.Brand.electricGreen)
                .textCase(.uppercase)
                .decorative()
            Text(model.challenge.localizedTitle)
                .font(.Archivo.title)
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
        .padding(.horizontal, Metrics.preferredPadding)
        .padding(.top, Metrics.large)
    }

    // MARK: - Podium

    private func winnersView(participants: [Participant]) -> some View {
        HStack(alignment: .bottom, spacing: Metrics.small) {
            if participants.count >= 2 {
                PodiumSlotView(participant: participants[1], rank: 2, avatarSize: avatarSizeOther)
            }
            if !participants.isEmpty {
                PodiumSlotView(participant: participants[0], rank: 1, avatarSize: avatarSizeFirst)
            }
            if participants.count >= 3 {
                PodiumSlotView(participant: participants[2], rank: 3, avatarSize: avatarSizeOther)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Metrics.extraSmall)
    }

    // MARK: - Others

    private var othersSection: some View {
        let others = model.otherParticipants
        return VStack(alignment: .leading, spacing: Metrics.small) {
            if !others.isEmpty {
                Text(String(localized: "Others"))
                    .font(.caption.weight(.heavy))
                    .fontDesign(.monospaced)
                    .tracking(2)
                    .foregroundStyle(Color.Brand.electricGreen)
                    .textCase(.uppercase)
                    .accessibilityLabel(String(localized: "Others"))
                    .accessibleHeader()
            }
            if others.isEmpty {
                Text(LocalizedText.onlyParticipantsCompeted(model.challenge.participants.count))
                    .font(.app(.subheadline))
                    .foregroundStyle(Color.Brand.labelSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Metrics.extraHuge)
            } else {
                LazyVStack(spacing: Metrics.mini) {
                    ForEach(others) { entry in
                        OthersRowView(rank: entry.rank, participant: entry.participant)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Metrics.preferredPadding)
        .padding(.top, Metrics.medium)
        .padding(.bottom, Metrics.extraHuge)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ChallengeOverviewComponent(model: ChallengeOverviewComponentModelMock())
    }
}
#endif
