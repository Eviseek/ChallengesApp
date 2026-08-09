//
//  ChallengesFlowCoordinator.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 05.03.2026.
//

import FuturedArchitecture
import SwiftUI

@Observable
final class ChallengesFlowCoordinator: @MainActor NavigationStackCoordinator {

    // MARK: - Public Properties

    var path: [Destination] = []
    var modalCover: ModalCoverModel<Destination>?

    // MARK: - Private Properties

    private var authenticatedContainer: AuthenticatedContainer

    // MARK: - Init

    init(authenticatedContainer: AuthenticatedContainer) {
        self.authenticatedContainer = authenticatedContainer
    }

    // MARK: - Public Methods

    static func rootView(with instance: ChallengesFlowCoordinator) -> some View {
        NavigationStackFlow(coordinator: instance) {
            ChallengesComponent(
                model: ChallengesComponentModel(
                    challengeService: instance.authenticatedContainer.challengeService) { [weak instance] event in
                        switch event {
                        case let .challengeDetail(challenge):
                            instance?.navigate(to: .challengeDetail(challenge))
                        case let .challengeOverview(challenge):
                            instance?.navigate(to: .challengeOverview(challenge))
                        }
                }
            )
        }
    }

    @ViewBuilder
    func scene(for destination: Destination) -> some View {
        switch destination {
        case let .challengeDetail(challenge):
            ChallengeDetailComponent(
                model: ChallengeDetailComponentModel(
                    challenge: challenge,
                    challengeService: self.authenticatedContainer.challengeService) { _ in })
        case let .challengeOverview(challenge):
            ChallengeOverviewComponent(
                model: ChallengeOverviewComponentModel(
                    challenge: challenge,
                    challengeService: self.authenticatedContainer.challengeService) { _ in })
        }
    }
}

extension ChallengesFlowCoordinator {
    nonisolated enum Destination: CaseIdentifiable {
        case challengeDetail(Challenge)
        case challengeOverview(Challenge)

        var id: String {
            switch self {
            case .challengeDetail:
                "challengeDetail"
            case .challengeOverview:
                "challengeOverview"
            }
        }
    }
}
