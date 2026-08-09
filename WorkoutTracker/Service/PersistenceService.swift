//
//  PersistenceService.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 19.05.2026.
//

import Foundation
import OSLog
import SwiftData

enum PersistenceServiceEvent {
    case exercisesUpdated([Exercise])
}

protocol PersistenceService {
    /// Returns every exercise cached on the device.
    func fetchAllExercises() async -> [Exercise]
    /// Overwrites the cached exercises with `exercises`, inserting new ones and deleting any that are no longer present.
    func replaceAll(exercises: [Exercise]) async
    /// Returns the cached workout history, excluding the current (in-progress or paused) workout.
    func fetchAllWorkouts() async -> [Workout]
    /// Overwrites the cached workout history with `workouts`, leaving the current workout untouched.
    func replaceAll(workouts: [Workout]) async
    /// Inserts or updates a single workout by id. Pass `isCurrent: true` to mark it the active workout, `false` to store it as history.
    func save(workout: Workout, isCurrent: Bool) async
    /// Removes a single workout from the local cache by id.
    func delete(workout: Workout) async
    /// Removes every cached workout, including the current one. Used when the user session ends.
    func deleteAllWorkouts() async
    /// Returns the single current (in-progress or paused) workout, or `nil` if there is none.
    func fetchCurrentWorkout() async -> Workout?
}

final class PersistenceServiceImpl: PersistenceService {

    // MARK: - Private Properties

    private let continuation: AsyncStream<PersistenceServiceEvent>.Continuation
    private let logger = Logger(subsystem: "app.eviseek.workoutTracker", category: "PersistenceService")
    private var modelContainer: ModelContainer
    private lazy var backgroundContext: ModelContext = {
        let context = ModelContext(modelContainer)
        context.autosaveEnabled = false
        return context
    }()

    // MARK: - Init

    private init(continuation: AsyncStream<PersistenceServiceEvent>.Continuation, inMemory: Bool) throws {
        self.continuation = continuation
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)

        modelContainer = try ModelContainer(for: ExerciseModel.self, WorkoutModel.self, configurations: configuration)
    }

    // MARK: - Public Methods

    static func makeServiceWithContainerListener(inMemory: Bool = false) throws -> (
        PersistenceService,
        AsyncStream<PersistenceServiceEvent>
    ) {
        let (stream, continuation) = AsyncStream.makeStream(of: PersistenceServiceEvent.self)
        return (try PersistenceServiceImpl(continuation: continuation, inMemory: inMemory), stream)
    }

    func fetchAllExercises() async -> [Exercise] {
        let descriptor = FetchDescriptor<ExerciseModel>()
        let models = (try? backgroundContext.fetch(descriptor)) ?? []
        return models.map { Exercise(id: $0.id, name: $0.name, muscleGroup: $0.muscleGroup, type: $0.type, description: $0.desc) }
    }

    func replaceAll(exercises: [Exercise]) async {
        let descriptor = FetchDescriptor<ExerciseModel>()
        let existing = (try? backgroundContext.fetch(descriptor)) ?? []

        let incomingIds = Set(exercises.map(\.id))
        let existingById = Dictionary(existing.map { ($0.id, $0) }) { first, _ in first }

        let toRemove = existing.filter { !incomingIds.contains($0.id) }

        for model in toRemove {
            backgroundContext.delete(model)
        }

        for exercise in exercises {
            if let model = existingById[exercise.id] {
                model.name = exercise.name
                model.muscleGroup = exercise.muscleGroup
                model.type = exercise.type
                model.desc = exercise.description
            } else {
                let model = ExerciseModel(id: exercise.id, name: exercise.name, muscleGroup: exercise.muscleGroup, type: exercise.type, desc: exercise.description)
                backgroundContext.insert(model)
            }
        }

        try? backgroundContext.save()
        continuation.yield(.exercisesUpdated(exercises))
    }

    func fetchAllWorkouts() async -> [Workout] {
        let descriptor = FetchDescriptor<WorkoutModel>(predicate: #Predicate { !$0.isCurrent })
        let models = (try? backgroundContext.fetch(descriptor)) ?? []
        return models.map { Workout(id: $0.id, name: $0.name, date: $0.date, state: $0.state, duration: $0.duration, exerciseSets: $0.exerciseSets) }
    }

    func fetchCurrentWorkout() async -> Workout? {
        var descriptor = FetchDescriptor<WorkoutModel>(predicate: #Predicate { $0.isCurrent })
        descriptor.fetchLimit = 1
        var workout: Workout?

        if let model = try? backgroundContext.fetch(descriptor).first {
            workout = Workout(id: model.id, name: model.name, date: model.date, state: model.state, duration: model.duration, exerciseSets: model.exerciseSets)
        }
        return workout
    }

    func replaceAll(workouts: [Workout]) async {
        let descriptor = FetchDescriptor<WorkoutModel>(predicate: #Predicate { !$0.isCurrent })
        let existing = (try? backgroundContext.fetch(descriptor)) ?? []

        let existingIds = Set(existing.map(\.id))
        let incomingIds = Set(workouts.map(\.id))

        let toRemove = existing.filter { !incomingIds.contains($0.id) }
        let toAdd = workouts.filter { !existingIds.contains($0.id) }

        for model in toRemove {
            backgroundContext.delete(model)
        }

        for workout in toAdd {
            let model = WorkoutModel(id: workout.id, name: workout.name, date: workout.date, state: workout.state, duration: workout.duration, exerciseSets: workout.exerciseSets)
            backgroundContext.insert(model)
        }

        do {
            try backgroundContext.save()
        } catch {
            logger.error("Error saving workouts: \(error)")
        }
    }

    func save(workout: Workout, isCurrent: Bool) async {
        let id = workout.id
        var descriptor = FetchDescriptor<WorkoutModel>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1

        if let existing = try? backgroundContext.fetch(descriptor).first {
            existing.name = workout.name
            existing.date = workout.date
            existing.state = workout.state
            existing.duration = workout.duration
            existing.exerciseSets = workout.exerciseSets
            existing.isCurrent = isCurrent
        } else {
            backgroundContext.insert(WorkoutModel(id: workout.id, name: workout.name, date: workout.date, state: workout.state, duration: workout.duration, exerciseSets: workout.exerciseSets, isCurrent: isCurrent))
        }

        try? backgroundContext.save()
    }

    func delete(workout: Workout) async {
        let id = workout.id
        var descriptor = FetchDescriptor<WorkoutModel>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let existing = try? backgroundContext.fetch(descriptor).first else { return }
        backgroundContext.delete(existing)
        try? backgroundContext.save()
    }

    func deleteAllWorkouts() async {
        do {
            try backgroundContext.delete(model: WorkoutModel.self)
            try backgroundContext.save()
        } catch {
            logger.error("Error deleting all workouts: \(error)")
        }
    }
}
