//
//  ChallengeDetailComponentModel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 13.03.2026.
//

import FuturedArchitecture
import SwiftUI

protocol ChallengeDetailComponentModelProtocol: ComponentModel, LoadableComponentModel {
    var challenge: Challenge { get }
    var leaderboard: [LeaderboardEntry] { get }

    func onAppear() async
    func retry() async
}

@Observable
final class ChallengeDetailComponentModel: ChallengeDetailComponentModelProtocol {

    // MARK: - Public Properties

    let onEvent: (Event) -> Void
    var challenge: Challenge
    var isLoading: Bool = false
    var loadError: AppError?

    var leaderboard: [LeaderboardEntry] {
        challenge.participants.ranked()
    }

    var isContentEmpty: Bool { challenge.participants.isEmpty }

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
        await fetchParticipants()
    }

    // MARK: - Private Methods

    private func fetchParticipants() async {
        guard challenge.participants.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            challenge.participants = try await challengeService.fetchParticipants(for: challenge)
            challengeService.updateCacheWithParticipants(challenge.participants, for: challenge)
            loadError = nil
        } catch {
            loadError = error
        }
    }
}

extension ChallengeDetailComponentModel {
    enum Event {
    }
}

#if DEBUG
@Observable
final class ChallengeDetailComponentModelMock: ChallengeDetailComponentModelProtocol {
    typealias Event = ChallengeDetailComponentModel.Event

    var onEvent: (Event) -> Void = { _ in }
    var challenge: Challenge = Challenge.mock
    var isLoading: Bool = false
    var loadError: AppError?

    var leaderboard: [LeaderboardEntry] {
        challenge.participants.ranked()
    }

    var isContentEmpty: Bool { challenge.participants.isEmpty }

    func onAppear() async { }
    func retry() async { }
}
#endif
