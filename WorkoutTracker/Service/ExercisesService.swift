//
//  ExercisesService.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 27.05.2026.
//

import Foundation
import FuturedArchitecture
import OSLog

protocol ExercisesService {
    var exercises: [Exercise] { get }
    var isLoaded: Bool { get }
}

final class ExercisesServiceImpl: ExercisesService {

    // MARK: - Public Properties

    var exercises: [Exercise] {
        dataCache.value.exercises
    }

    var isLoaded: Bool {
        dataCache.value.exercisesLoaded
    }

    // MARK: - Private Properties

    private let logger: Logger = Logger(subsystem: "app.eviseek.workoutTracker", category: "ExercisesService")
    private let listeningTask: Task<Void, Never>
    private let fetchTask: Task<Void, Never>
    private let dataCache: DataCache<DataCacheModel>
    private let userDefaultsService: UserDefaultsService
    private let firebaseService: FirebaseService
    private let persistenceService: PersistenceService

    // MARK: - Init

    init(
        dataCache: DataCache<DataCacheModel>,
        userDefaultsService: UserDefaultsService,
        firebaseService: FirebaseService,
        persistenceService: PersistenceService,
        updateStream: AsyncStream<PersistenceServiceEvent>
    ) {
        self.dataCache = dataCache
        self.userDefaultsService = userDefaultsService
        self.firebaseService = firebaseService
        self.persistenceService = persistenceService

        listeningTask = Task { [dataCache, updateStream] in
            for await change in updateStream {
                switch change {
                case let .exercisesUpdated(exercises):
                    dataCache.update(\.exercises, with: exercises)
                    dataCache.update(\.exercisesLoaded, with: true)
                }
            }
        }

        fetchTask = Task { [userDefaultsService, firebaseService, persistenceService, dataCache, logger] in
            // Use the on-device cache only if it isn't stale AND actually has data. An empty
            // cache with a fresh timestamp means the store didn't persist (e.g. the in-memory
            // fallback after an on-disk failure), so re-fetch instead of trusting the timestamp.
            if !ExercisesServiceImpl.shouldRefreshExercises(using: userDefaultsService) {
                let cached = await persistenceService.fetchAllExercises()
                if !cached.isEmpty {
                    dataCache.update(\.exercises, with: cached)
                    dataCache.update(\.exercisesLoaded, with: true)
                    return
                }
            }
            do {
                let exercises = try await firebaseService.fetchAllExercises()
                await persistenceService.replaceAll(exercises: exercises)
                dataCache.update(\.exercises, with: exercises)
                dataCache.update(\.exercisesLoaded, with: true)
                userDefaultsService.saveExercisesUpdatedDate(Date())
            } catch {
                logger.error("Exercise fetch failed: \(error)")
                let cached = await persistenceService.fetchAllExercises()
                dataCache.update(\.exercises, with: cached)
                dataCache.update(\.exercisesLoaded, with: true)
            }
        }
    }

    deinit {
        fetchTask.cancel()
        listeningTask.cancel()
    }

    // MARK: - Private Methods

    private static func shouldRefreshExercises(using service: UserDefaultsService) -> Bool {
        guard let last = service.getExercisesUpdatedDate() else { return true }
        return Date.now.timeIntervalSince(last) > 7 * 24 * 3_600
    }
}
