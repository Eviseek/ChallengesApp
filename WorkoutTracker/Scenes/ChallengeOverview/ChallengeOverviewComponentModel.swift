//
//  ChallengeOverviewComponentModel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 23.04.2026.
//

import FuturedArchitecture
import Observation

protocol ChallengeOverviewComponentModelProtocol: ComponentModel, LoadableComponentModel {
    var challenge: Challenge { get }
    var otherParticipants: [LeaderboardEntry] { get }

    func onAppear() async
    func retry() async
}

@Observable
final class ChallengeOverviewComponentModel: ChallengeOverviewComponentModelProtocol {

    // MARK: - Public Properties

    let onEvent: (Event) -> Void
    var challenge: Challenge
    var isLoading: Bool = true
    var loadError: AppError?

    // Ranked participants below the podium (rank 4 onwards) for the "Others" list.
    var otherParticipants: [LeaderboardEntry] {
        Array(challenge.participants.ranked(onlyScoring: false).dropFirst(3))
    }

    // MARK: - Private Properties

    private let challengeService: ChallengeService

    // MARK: - Init

    init(
        challenge: Challenge,
        challengeService: ChallengeService,
        onEvent: @escaping (Event) -> Void
    ) {
        self.challenge = challenge
        self.challengeService = challengeService
        self.onEvent = onEvent
    }

    // MARK: - Public Methods

    func onAppear() async {
        await fetchParticipants()
    }

    func retry() async {
        isLoading = true
        await fetchParticipants()
    }

    // MARK: - Private Methods

    private func fetchParticipants() async {
        do {
            defer { isLoading = false }
            challenge.participants = try await challengeService.fetchParticipants(for: challenge)
            loadError = nil
        } catch {
            loadError = error
        }
    }
}

extension ChallengeOverviewComponentModel {
    enum Event {
    }
}

#if DEBUG
@Observable
final class ChallengeOverviewComponentModelMock: ChallengeOverviewComponentModelProtocol {
    typealias Event = ChallengeOverviewComponentModel.Event

    var onEvent: (Event) -> Void = { _ in }
    var challenge: Challenge = Challenge.mockFinished
    var isLoading: Bool = false
    var loadError: AppError?

    // Ranked participants below the podium (rank 4 onwards) for the "Others" list.
    var otherParticipants: [LeaderboardEntry] {
        Array(challenge.participants.ranked(onlyScoring: false).dropFirst(3))
    }

    func onAppear() async { }
    func retry() async { }
}
#endif
