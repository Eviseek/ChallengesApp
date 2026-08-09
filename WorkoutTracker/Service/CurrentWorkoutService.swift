//
//  CurrentWorkoutService.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 09.04.2026.
//

import ActivityKit
import FuturedArchitecture
import OSLog
import SwiftUI

protocol CurrentWorkoutService {
    var currentWorkout: Workout { get }
    var workoutSets: [ExerciseSet] { get }
    var hasActiveWorkout: Bool { get }
    var hasEmptySets: Bool { get }

    func startWorkout(_ workout: Workout?)
    func updateWorkoutName(_ name: String)
    @discardableResult
    func addSet(for exercise: Exercise) -> UUID
    func updateSet(for exercise: Exercise, at setIndex: Int, reps: Int?, weight: Double?)
    func updateSet(for exercise: Exercise, at setIndex: Int, duration: Int?)
    func updateSet(for exercise: Exercise, at setIndex: Int, notes: String?)
    func deleteSet(for exercise: Exercise, at index: Int)
    func removeExercise(_ exercise: Exercise)
    func finishWorkout() async throws(AppError)
    func pauseWorkout()
    func resumeWorkout()
    func deleteWorkout()
    func dismissWorkout()
    func endSession() async
    func updateActiveSet(_ set: ExerciseSet)
}

final class CurrentWorkoutServiceImpl: CurrentWorkoutService {

    // MARK: - Public Properties

    var currentWorkout: Workout {
        get { dataCache.value.currentWorkout ?? Workout() }
        set { dataCache.update(\.currentWorkout, with: newValue) }
    }

    var workoutSets: [ExerciseSet] {
        currentWorkout.exerciseSets
    }

    var hasActiveWorkout: Bool {
        dataCache.value.currentWorkout != nil
    }

    var hasEmptySets: Bool {
        currentWorkout.exerciseSets.contains { exerciseSet in
            if exerciseSet.exercise.type == .duration {
                return exerciseSet.duration == nil
            } else {
                return exerciseSet.reps == nil && exerciseSet.weight == nil
            }
        }
    }

    // MARK: - Private Properties

    private let dataCache: DataCache<DataCacheModel>
    // Internal (not private) so the Live Activity helpers in CurrentWorkoutService+LiveActivity.swift can reach them.
    let liveActivityService: LiveActivityService
    private let firebaseService: FirebaseService
    private let persistenceService: PersistenceService
    private let contributionsResource: ContributionsResourceProtocol
    private var timerTask: Task<Void, Never>?
    private var observationTasks: [Task<Void, Never>] = []

    let logger = Logger(subsystem: "app.eviseek.workoutTracker", category: "CurrentWorkoutService")

    // MARK: - Init

    init(
        dataCache: DataCache<DataCacheModel>,
        liveActivityService: LiveActivityService,
        firebaseService: FirebaseService,
        persistenceService: PersistenceService,
        contributionsResource: ContributionsResourceProtocol
    ) {
        self.dataCache = dataCache
        self.liveActivityService = liveActivityService
        self.firebaseService = firebaseService
        self.persistenceService = persistenceService
        self.contributionsResource = contributionsResource
        restoreWorkoutIfNeeded(restartActivity: true)
        observeAppTermination()
        observeDidEnterBackground()
        observeEnteringForeground()
    }

    // MARK: - Public Methods

    func startWorkout(_ workout: Workout? = nil) {
        guard dataCache.value.currentWorkout == nil else { return }
        if let workout {
            currentWorkout = repeatedWorkout(workout)
        } else {
            currentWorkout = Workout()
        }
        currentWorkout.state = .running
        startTimer()
        Task { await startActivity(startDate: startDate) }
    }

    func updateWorkoutName(_ name: String) {
        currentWorkout.updateName(name)
    }

    @discardableResult
    func addSet(for exercise: Exercise) -> UUID {
        currentWorkout.addSet(for: exercise)
    }

    func updateSet(for exercise: Exercise, at setIndex: Int, reps: Int?, weight: Double?) {
        currentWorkout.updateSet(for: exercise, at: setIndex, reps: reps, weight: weight)
    }

    func updateSet(for exercise: Exercise, at setIndex: Int, duration: Int?) {
        currentWorkout.updateSet(for: exercise, at: setIndex, duration: duration)
    }

    func updateSet(for exercise: Exercise, at setIndex: Int, notes: String?) {
        currentWorkout.updateSet(for: exercise, at: setIndex, notes: notes)
    }

    func deleteSet(for exercise: Exercise, at index: Int) {
        currentWorkout.deleteSet(for: exercise, at: index)
    }

    func removeExercise(_ exercise: Exercise) {
        currentWorkout.removeExercise(exercise)
    }

    func finishWorkout() async throws(AppError) {
        stopTimer()
        guard !currentWorkout.exerciseSets.isEmpty else {
            deleteWorkout()
            return
        }
        do {
            try await firebaseService.saveWorkout(currentWorkout, userId: dataCache.value.currentUser.id)
            if let activeChallenge = dataCache.value.challenges.first(where: { $0.isActive }) {
                let contributions = contributionsResource.contributions(for: activeChallenge.goal, workout: currentWorkout)
                if !contributions.isEmpty {
                    try await firebaseService.saveContributions(
                        contributions,
                        for: activeChallenge,
                        userId: dataCache.value.currentUser.id,
                        displayName: dataCache.value.currentUser.displayName
                    )
                }
            }
            await persistenceService.save(workout: currentWorkout, isCurrent: false)
            updateWorkoutCache()
            await stopActivity()
        } catch AppError.offline {
            pauseWorkout()
            await persistenceService.save(workout: currentWorkout, isCurrent: true)
            throw AppError.offline
        } catch {
            throw AppError.saveFailed
        }
    }

    func pauseWorkout() {
        currentWorkout.state = .paused
        stopTimer()
        Task { await pauseActivity(pausedSeconds: currentWorkout.duration) }
    }

    func resumeWorkout() {
        currentWorkout.state = .running
        startTimer()
        Task { await updateActivity(startDate: startDate) }
    }

    func deleteWorkout() {
        stopTimer()
        let workout = dataCache.value.currentWorkout
        dataCache.update(\.currentWorkout, with: nil)
        Task {
            if let workout {
                await persistenceService.delete(workout: workout)
            }
            await stopActivity()
        }
    }

    // For state when workout detail is not shown, but workout is still running
    // If workout is paused, set only duration not state
    func dismissWorkout() {
        if currentWorkout.state == .paused {
            return
        }
        currentWorkout.state = .running
    }

    func updateActiveSet(_ set: ExerciseSet) {
        Task { await updateActivity(activeSet: set) }
    }

    // Discards the in-progress workout without saving it when the user session ends.
    // Lifecycle observers are cancelled first so a backgrounding notification can't re-persist the workout afterwards.
    func endSession() async {
        observationTasks.forEach { $0.cancel() }
        observationTasks = []
        stopTimer()
        dataCache.update(\.currentWorkout, with: nil)
        await stopActivity()
    }

    // MARK: - Private Methods

    private func repeatedWorkout(_ workout: Workout) -> Workout {
        let repeatedSets = workout.exerciseSets.map { set in
            ExerciseSet(
                exercise: set.exercise,
                reps: nil,
                weight: nil,
                duration: nil,
                notes: nil,
                placeholder: .init(
                    reps: set.reps,
                    weight: set.weight,
                    duration: set.duration,
                    notes: set.notes
                )
            )
        }

        return Workout(
            id: UUID().uuidString,
            name: workout.name,
            date: Date(),
            duration: 0,
            exerciseSets: repeatedSets
        )
    }

    private func updateWorkoutCache() {
        var workouts = dataCache.value.workouts
        workouts.append(currentWorkout)
        dataCache.update(\.workouts, with: workouts)
        dataCache.update(\.currentWorkout, with: nil)
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if !Task.isCancelled {
                    currentWorkout.duration += 1
                }
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    deinit {
        timerTask?.cancel()
        observationTasks.forEach { $0.cancel() }
    }
}

// MARK: - App Lifecycle

extension CurrentWorkoutServiceImpl {
    private func observeDidEnterBackground() {
        let task = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(named: UIApplication.didEnterBackgroundNotification) {
                guard let self else { return }
                saveWorkoutIfNeeded()
            }
        }
        observationTasks.append(task)
    }

    private func observeEnteringForeground() {
        let task = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(named: UIApplication.willEnterForegroundNotification) {
                guard let self else { return }
                restoreWorkoutIfNeeded()
            }
        }
        observationTasks.append(task)
    }

    // Termination stays synchronous (selector-based, auto-removed on dealloc): the process is killed
    // right after this returns, so an async task wouldn't reliably run before exit.
    private func observeAppTermination() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }

    @objc
    private func handleWillTerminate() {
        saveWorkoutIfNeeded(asPaused: true)
        Task { await stopActivity() }
        // The task is only queued, not executed yet. RunLoop keeps the main loop
        // spinning so the task actually runs before the process exits.
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
    }

    private func restartActivityIfNeeded() async {
        guard let workout = dataCache.value.currentWorkout else { return }
        let state = WorkoutOverviewAttributes.ContentState(
            startDate: startDate,
            workoutName: workout.name,
            pausedAtSeconds: workout.state == .paused ? workout.duration : nil
        )
        do {
            try await liveActivityService.start(with: state)
        } catch {
            logger.error("Restart live activity error: \(error)")
        }
    }

    private func saveWorkoutIfNeeded(asPaused: Bool = false) {
        guard var workout = dataCache.value.currentWorkout, !workout.exerciseSets.isEmpty else { return }
        if asPaused { workout.state = .paused }
        Task { await persistenceService.save(workout: workout, isCurrent: true) }
    }

    private func restoreWorkoutIfNeeded(restartActivity: Bool = false) {
        Task {
            guard let workout = await persistenceService.fetchCurrentWorkout() else { return }
            dataCache.update(\.currentWorkout, with: workout)
            syncTimerIfNeeded()
            if restartActivity {
                await restartActivityIfNeeded()
            }
        }
    }

    private func syncTimerIfNeeded() {
        guard dataCache.value.currentWorkout != nil,
              currentWorkout.state == .running,
              let startDate = liveActivityService.activity?.content.state.startDate else {
            return
        }
        currentWorkout.duration = Int(Date.now.timeIntervalSince(startDate))
        startTimer()
    }
}
