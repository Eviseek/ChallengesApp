//
//  WorkoutsService.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 05.06.2026.
//

import Foundation
import FuturedArchitecture
import OSLog

protocol WorkoutsService {
    var workouts: [Workout] { get }

    func loadWorkouts() async throws(AppError)
    func saveWorkout(_ workout: Workout) async throws(AppError)
    func deleteWorkout(_ workout: Workout) async throws(AppError)
}

final class WorkoutsServiceImpl: WorkoutsService {

    // MARK: - Public Properties

    var workouts: [Workout] {
        dataCache.value.workouts
    }

    // MARK: - Private Properties

    private let logger = Logger(subsystem: "app.eviseek.workoutTracker", category: "WorkoutsService")
    private let dataCache: DataCache<DataCacheModel>
    private let firebaseService: FirebaseService
    private let networkMonitorService: NetworkMonitorService
    private let persistenceService: PersistenceService

    // MARK: - Init

    init(
        dataCache: DataCache<DataCacheModel>,
        firebaseService: FirebaseService,
        networkMonitorService: NetworkMonitorService,
        persistenceService: PersistenceService
    ) {
        self.dataCache = dataCache
        self.firebaseService = firebaseService
        self.networkMonitorService = networkMonitorService
        self.persistenceService = persistenceService
    }

    // MARK: - Public Methods

    func loadWorkouts() async throws(AppError) {
        if !networkMonitorService.isConnected {
            let cached = await persistenceService.fetchAllWorkouts()
            guard !cached.isEmpty else { throw AppError.offline }
            dataCache.update(\.workouts, with: cached)
        } else {
            let remote = try await firebaseService.fetchWorkouts(
                with: dataCache.value.exercises,
                userId: dataCache.value.currentUser.id
            )
            await persistenceService.replaceAll(workouts: remote)
            dataCache.update(\.workouts, with: remote)
        }
    }

    func saveWorkout(_ workout: Workout) async throws(AppError) {
        try await firebaseService.saveWorkout(workout, userId: dataCache.value.currentUser.id)
        updateCache(with: workout)
        await persistenceService.save(workout: workout, isCurrent: false)
    }

    func deleteWorkout(_ workout: Workout) async throws(AppError) {
        do {
            try await firebaseService.removeWorkout(workout, userId: dataCache.value.currentUser.id)
            var updatedWorkouts = workouts
            updatedWorkouts.removeAll { $0.id == workout.id }
            dataCache.update(\.workouts, with: updatedWorkouts)
            await persistenceService.delete(workout: workout)
        } catch {
            logger.error("Error deleting workout: \(error)")
            throw error
        }
    }

    // MARK: - Private Methods

    private func updateCache(with workout: Workout) {
        var workouts = dataCache.value.workouts
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index] = workout
        }
        dataCache.update(\.workouts, with: workouts)
    }
}
