//
//  ChallengeService.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 29.04.2026.
//

import Foundation
import FuturedArchitecture
import OSLog

protocol ChallengeService {
    var activeChallenge: Challenge? { get }
    var pastChallenges: [Challenge] { get }

    func detectEndedChallenge() -> Challenge?
    func syncActiveChallenge() async throws(AppError)
    func fetchAllChallenges() async throws(AppError)
    func fetchParticipants(for challenge: Challenge) async throws(AppError) -> [Participant]
    func updateCacheWithParticipants(_ participants: [Participant], for challenge: Challenge)
    func loadChallengesIfNeeded() async throws(AppError)
}

final class ChallengeServiceImpl: ChallengeService {

    // MARK: - Public Properties

    var activeChallenge: Challenge? {
        dataCache.value.challenges.first { $0.isActive }
    }

    var pastChallenges: [Challenge] {
        dataCache.value.challenges.filter { $0.isPast }
    }

    // MARK: - Private Properties

    private let logger = Logger(subsystem: "app.eviseek.workoutTracker", category: "ChallengeService")
    private let dataCache: DataCache<DataCacheModel>
    private let defaultsService: UserDefaultsService
    private let firebaseService: FirebaseService

    // MARK: - Init

    init(
        dataCache: DataCache<DataCacheModel>,
        defaultsService: UserDefaultsService,
        firebaseService: FirebaseService
    ) {
        self.dataCache = dataCache
        self.defaultsService = defaultsService
        self.firebaseService = firebaseService
    }

    // MARK: - Public Methods

    func detectEndedChallenge() -> Challenge? {
        guard let activeChallengeId = defaultsService.getActiveChallengeId() else {
            if let activeId = dataCache.value.challenges.first(where: { $0.isActive })?.id {
                defaultsService.saveActiveChallengeId(activeId)
            }
            return nil
        }

        let previousChallenge = dataCache.value.challenges.first { $0.id == activeChallengeId }
        let activeChallenge = dataCache.value.challenges.first { $0.isActive }

        var endedChallenge: Challenge?
        if let previousChallenge, previousChallenge != activeChallenge {
            endedChallenge = previousChallenge
            if let activeChallenge {
                defaultsService.saveActiveChallengeId(activeChallenge.id)
            }
        } else if previousChallenge == nil, let activeChallenge {
            defaultsService.saveActiveChallengeId(activeChallenge.id)
        }
        if activeChallenge == nil {
            defaultsService.clearActiveChallengeId()
        }
        return endedChallenge
    }

    func fetchAllChallenges() async throws(AppError) {
        // Connectivity is enforced once, at the FirebaseService boundary; it re-throws the
        // typed `.offline`/`.fetchFailed`, so no separate guard or error remap is needed here.
        let challenges = try await firebaseService.fetchChallenges(with: dataCache.value.exercises)
        dataCache.update(\.challenges, with: challenges)
    }

    func syncActiveChallenge() async throws(AppError) {
        guard let activeChallengeId = defaultsService.getActiveChallengeId(),
              let index = dataCache.value.challenges.firstIndex(where: { $0.id == activeChallengeId }) else {
            return
        }
        var challenge = dataCache.value.challenges[index]
        challenge.participants = try await firebaseService.fetchParticipants(for: challenge, currentUserId: dataCache.value.currentUser.id)
        // Re-resolve by id: the await above may have let a concurrent refresh replace the array, invalidating `index`.
        guard let currentIndex = dataCache.value.challenges.firstIndex(where: { $0.id == challenge.id }) else { return }
        dataCache.update(\.challenges[currentIndex], with: challenge)
    }

    func fetchParticipants(for challenge: Challenge) async throws(AppError) -> [Participant] {
        do {
            let participants = try await firebaseService.fetchParticipants(for: challenge, currentUserId: dataCache.value.currentUser.id)
                .sorted { $0.value > $1.value }
            return participants
        } catch {
            logger.error("Error fetching participants: \(error)")
            throw AppError.fetchFailed
        }
    }

    func updateCacheWithParticipants(_ participants: [Participant], for challenge: Challenge) {
        guard let index = dataCache.value.challenges.firstIndex(where: { $0.id == challenge.id }) else { return }
        var updated = challenge
        updated.participants = participants
        dataCache.update(\.challenges[index], with: updated)
    }

    func loadChallengesIfNeeded() async throws(AppError) {
        if activeChallenge == nil && pastChallenges.isEmpty {
            try await fetchAllChallenges()
        }
    }
}
