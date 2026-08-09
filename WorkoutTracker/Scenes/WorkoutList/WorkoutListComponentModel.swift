//
//  WorkoutListComponentModel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 05.03.2026.
//

import Foundation
import FuturedArchitecture
import Observation

protocol WorkoutListComponentModelProtocol: ComponentModel, LoadableComponentModel, Observable {
    var hasActiveWorkout: Bool { get }
    var workouts: [Workout] { get }
    var alertModel: AlertModel? { get set }
    var showsStartWorkoutButton: Bool { get }

    func onAppear() async
    func retry() async
    func openWorkoutDetail()
    func openWorkoutSummary(_ workout: Workout)
    func deleteWorkout(_ workout: Workout) async
}

@Observable
final class WorkoutListComponentModel: WorkoutListComponentModelProtocol {

    // MARK: - Public Properties

    let onEvent: (Event) -> Void
    var loadError: AppError?
    var alertModel: AlertModel?

    var isLoading: Bool {
        !exercisesService.isLoaded
    }

    var workouts: [Workout] {
        workoutsService.workouts
    }

    var hasActiveWorkout: Bool {
        currentWorkoutService.hasActiveWorkout
    }

    var isContentEmpty: Bool { workouts.isEmpty }

    // Only offer Start Workout once content/empty is shown — hidden while loading or on the offline/error screen.
    var showsStartWorkoutButton: Bool {
        guard !hasActiveWorkout else { return false }
        switch screenState {
        case .content, .empty:
            return true
        case .loading, .error:
            return false
        }
    }

    // MARK: - Private Properties

    private let workoutsService: WorkoutsService
    private let exercisesService: ExercisesService
    private let currentWorkoutService: CurrentWorkoutService
    private let challengeService: ChallengeService

    // MARK: - Init

    init(
        workoutsService: WorkoutsService,
        exercisesService: ExercisesService,
        currentWorkoutService: CurrentWorkoutService,
        challengeService: ChallengeService,
        onEvent: @escaping (Event) -> Void
    ) {
        self.workoutsService = workoutsService
        self.exercisesService = exercisesService
        self.currentWorkoutService = currentWorkoutService
        self.challengeService = challengeService
        self.onEvent = onEvent
    }

    // MARK: - Public Methods

    func onAppear() async {
        await loadContent()
    }

    func retry() async {
        await loadContent()
    }

    func openWorkoutDetail() {
        onEvent(.workoutDetail)
    }

    func openWorkoutSummary(_ workout: Workout) {
        onEvent(.workoutSummary(workout))
    }

    func deleteWorkout(_ workout: Workout) async {
        do {
            try await workoutsService.deleteWorkout(workout)
        } catch {
            alertModel = AlertModel(error: error)
        }
    }

    // MARK: - Private Methods

    private func loadContent() async {
        guard exercisesService.isLoaded else { return }
        do {
            loadError = nil
            try await workoutsService.loadWorkouts()
            try await challengeService.loadChallengesIfNeeded()
        } catch {
            if workouts.isEmpty { loadError = error }
        }
    }
}

extension WorkoutListComponentModel {
    enum Event {
        case workoutDetail
        case workoutSummary(Workout)
    }
}

#if DEBUG
@Observable
final class WorkoutListComponentModelMock: WorkoutListComponentModelProtocol {
    typealias Event = WorkoutListComponentModel.Event

    var onEvent: (Event) -> Void = { _ in }
    let isLoading: Bool = false
    var loadError: AppError?
    var alertModel: AlertModel?
    var hasActiveWorkout: Bool = false
    var workouts: [Workout] = Workout.mockData

    var isContentEmpty: Bool { workouts.isEmpty }

    var showsStartWorkoutButton: Bool {
        guard !hasActiveWorkout else { return false }
        switch screenState {
        case .content, .empty:
            return true
        case .loading, .error:
            return false
        }
    }

    func onAppear() async { }
    func retry() async { }
    func openWorkoutDetail() { }
    func openWorkoutSummary(_ workout: Workout) { }
    func deleteWorkout(_ workout: Workout) async { }
}
#endif
