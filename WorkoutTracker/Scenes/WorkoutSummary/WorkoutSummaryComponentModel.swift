//
//  WorkoutSummaryComponentModel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 12.03.2026.
//

import FuturedArchitecture
import Observation
import OSLog

protocol WorkoutSummaryComponentModelProtocol: ComponentModel, Observable {
    var workout: Workout { get set }
    var alertModel: AlertModel? { get set }
    var groupedExerciseSets: [(exercise: Exercise, sets: [ExerciseSet])] { get }

    func addSet(for exercise: Exercise)
    func updateSet(for exercise: Exercise, at setIndex: Int, reps: Int?, weight: Double?)
    func updateSet(for exercise: Exercise, at setIndex: Int, duration: Int?)
    func updateSet(for exercise: Exercise, at setIndex: Int, notes: String?)
    func deleteSet(for exercise: Exercise, at index: Int)
    func removeExercise(_ exercise: Exercise)
    /// Persists the workout. Returns `true` on success (or when there is nothing to save),
    /// `false` when the save failed — the caller uses this to decide whether to leave edit mode.
    func saveWorkout() async -> Bool
    func startRepeatedWorkout()
}

@Observable
final class WorkoutSummaryComponentModel: WorkoutSummaryComponentModelProtocol {

    // MARK: - Public Properties

    let onEvent: (Event) -> Void
    var workout: Workout
    var alertModel: AlertModel?

    var groupedExerciseSets: [(exercise: Exercise, sets: [ExerciseSet])] {
        workout.exerciseSets.groupedByExercise()
    }

    // MARK: - Private Properties

    private let logger = Logger(subsystem: "app.eviseek.workoutTracker", category: "WorkoutSummaryComponentModel")
    private let workoutsService: WorkoutsService
    private let workoutService: CurrentWorkoutService
    private var savedWorkout: Workout

    // MARK: - Init

    init(
        workout: Workout,
        workoutsService: WorkoutsService,
        workoutService: CurrentWorkoutService,
        onEvent: @escaping (Event) -> Void
    ) {
        self.workout = workout
        self.workoutsService = workoutsService
        self.workoutService = workoutService
        self.onEvent = onEvent
        self.savedWorkout = workout
    }

    // MARK: - Public Methods

    func addSet(for exercise: Exercise) {
        workout.addSet(for: exercise)
    }

    func updateSet(for exercise: Exercise, at setIndex: Int, reps: Int?, weight: Double?) {
        workout.updateSet(for: exercise, at: setIndex, reps: reps, weight: weight)
    }

    func updateSet(for exercise: Exercise, at setIndex: Int, duration: Int?) {
        workout.updateSet(for: exercise, at: setIndex, duration: duration)
    }

    func updateSet(for exercise: Exercise, at setIndex: Int, notes: String?) {
        workout.updateSet(for: exercise, at: setIndex, notes: notes)
    }

    func deleteSet(for exercise: Exercise, at index: Int) {
        workout.deleteSet(for: exercise, at: index)
    }

    func removeExercise(_ exercise: Exercise) {
        workout.removeExercise(exercise)
    }

    func saveWorkout() async -> Bool {
        guard savedWorkout != workout else { return true }
        do {
            try await workoutsService.saveWorkout(workout)
            savedWorkout = workout
            return true
        } catch {
            logger.error("Save workout failed: \(error)")
            alertModel = AlertModel(error: error)
            return false
        }
    }

    func startRepeatedWorkout() {
        workoutService.startWorkout(workout)
        onEvent(.startRepeatedWorkout)
    }
}

extension WorkoutSummaryComponentModel {
    enum Event {
        case startRepeatedWorkout
    }
}

#if DEBUG
@Observable
final class WorkoutSummaryComponentModelMock: WorkoutSummaryComponentModelProtocol {
    typealias Event = WorkoutSummaryComponentModel.Event

    var onEvent: (Event) -> Void = { _ in }
    // swiftlint:disable:next force_unwrapping
    var workout: Workout = Workout.mockData.first!
    var alertModel: AlertModel?
    let groupedExerciseSets: [(exercise: Exercise, sets: [ExerciseSet])] = []

    func addSet(for exercise: Exercise) {}
    func updateSet(for exercise: Exercise, at setIndex: Int, reps: Int?, weight: Double?) {}
    func updateSet(for exercise: Exercise, at setIndex: Int, duration: Int?) {}
    func updateSet(for exercise: Exercise, at setIndex: Int, notes: String?) {}
    func deleteSet(for exercise: Exercise, at index: Int) {}
    func removeExercise(_ exercise: Exercise) {}
    func saveWorkout() async -> Bool { true }
    func startRepeatedWorkout() {}
}
#endif
