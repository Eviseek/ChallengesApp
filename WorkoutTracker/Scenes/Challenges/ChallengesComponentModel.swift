//
//  ActiveChallengeComponentModel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 12.03.2026.
//

import FuturedArchitecture
import Observation

enum ChallengeComponentState: Equatable {
    case normal
    case challengeJustEnded(Challenge)
}

protocol ChallengesComponentModelProtocol: ComponentModel, LoadableComponentModel, Observable {
    var state: ChallengeComponentState { get }
    var alertModel: AlertModel? { get set }
    var activeChallenge: Challenge? { get }
    var pastChallenges: [Challenge] { get }
    var leaderboard: [LeaderboardEntry] { get }

    func onAppear() async
    func syncChallenges() async
    func retry() async
    func openChallengeDetail(_ challenge: Challenge)
    func openChallengeOverview(_ challenge: Challenge)
    func dismissChallengeEnded()
}

@Observable
final class ChallengesComponentModel: ChallengesComponentModelProtocol {

    // MARK: - Public Properties

    let onEvent: (Event) -> Void
    var state: ChallengeComponentState = .normal
    var alertModel: AlertModel?
    var isLoading: Bool = true
    var loadError: AppError?

    var activeChallenge: Challenge? {
        challengeService.activeChallenge
    }

    var pastChallenges: [Challenge] {
        challengeService.pastChallenges
    }

    var leaderboard: [LeaderboardEntry] {
        activeChallenge?.participants.ranked() ?? []
    }

    // MARK: - Private Properties

    private let challengeService: ChallengeService
    private var hasInitiallyLoaded = false

    // MARK: - Init

    init(
        challengeService: ChallengeService,
        onEvent: @escaping (Event) -> Void
    ) {
        self.challengeService = challengeService
        self.onEvent = onEvent
    }

    // MARK: - Public Methods

    func onAppear() async {
        await syncChallenges()
    }

    func syncChallenges() async {
        if let ended = challengeService.detectEndedChallenge() {
            state = .challengeJustEnded(ended)
        }
        await loadActiveChallenge()
    }

    // Retry from the fullscreen error state: reload only, skipping ended-challenge detection.
    func retry() async {
        hasInitiallyLoaded = false
        isLoading = true
        loadError = nil
        await loadActiveChallenge()
    }

    // MARK: - Private Methods

    // Fetches the challenge list before syncing so this scene owns its data dependency
    // instead of relying on the Workouts tab having loaded it.
    private func loadActiveChallenge() async {
        do {
            try await challengeService.loadChallengesIfNeeded()
            try await challengeService.syncActiveChallenge()
            loadError = nil
            if !hasInitiallyLoaded {
                hasInitiallyLoaded = true
                isLoading = false
            }
        } catch {
            if !hasInitiallyLoaded {
                hasInitiallyLoaded = true
                isLoading = false
                loadError = error
            } else {
                alertModel = AlertModel(error: error)
            }
        }
    }

    func openChallengeDetail(_ challenge: Challenge) {
        onEvent(.challengeDetail(challenge))
    }

    func openChallengeOverview(_ challenge: Challenge) {
        onEvent(.challengeOverview(challenge))
        state = .normal
    }

    func dismissChallengeEnded() {
        state = .normal
    }
}

extension ChallengesComponentModel {
    enum Event {
        case challengeDetail(Challenge)
        case challengeOverview(Challenge)
    }
}

#if DEBUG
@Observable
final class ActiveChallengeComponentModelMock: ChallengesComponentModelProtocol {
    typealias Event = ChallengesComponentModel.Event

    var onEvent: (Event) -> Void = { _ in }
    let state: ChallengeComponentState = .normal
    var alertModel: AlertModel?
    var isLoading: Bool = false
    var loadError: AppError?
    var activeChallenge: Challenge? = .mock
    var pastChallenges: [Challenge] = [.mockFinished]

    var leaderboard: [LeaderboardEntry] {
        activeChallenge?.participants.ranked() ?? []
    }

    func onAppear() async { }
    func syncChallenges() async { }
    func retry() async { }
    func openChallengeDetail(_ challenge: Challenge) { }
    func openChallengeOverview(_ challenge: Challenge) { }
    func dismissChallengeEnded() { }
}
#endif
