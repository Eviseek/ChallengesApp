//
//  WorkoutDetailFlowCoordinator.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 14.03.2026.
//

import FuturedArchitecture
import SwiftUI

@Observable
final class WorkoutDetailFlowCoordinator: @MainActor NavigationStackCoordinator {

    enum Event {
        case dismiss
    }

    // MARK: - Public Properties

    var path: [Destination] = []
    var modalCover: ModalCoverModel<Destination>?

    // MARK: - Private Properties

    private var authenticatedContainer: AuthenticatedContainer
    private var onEvent: (Event) -> Void

    // MARK: - Init

    init(authenticatedContainer: AuthenticatedContainer, onEvent: @escaping (Event) -> Void) {
        self.authenticatedContainer = authenticatedContainer
        self.onEvent = onEvent
    }

    // MARK: - Public Methods

    static func rootView(with instance: WorkoutDetailFlowCoordinator) -> some View {
        NavigationStackFlow(coordinator: instance) {
            WorkoutDetailComponent(
                model: WorkoutDetailComponentModel(
                    workoutService: instance.authenticatedContainer.currentWorkoutService) { [weak instance] event in
                        switch event {
                        case .openExerciseCategories:
                            instance?.navigate(to: .categoryList)
                        case .dismiss:
                            instance?.onEvent(.dismiss)
                        }
                }
            )
        }
    }

    @ViewBuilder
    func scene(for destination: Destination) -> some View {
        switch destination {
        case let .exerciseList(muscleGroup):
            ExerciseListComponent(
                model: ExerciseListComponentModel(
                    exercisesService: authenticatedContainer.exercisesService,
                    currentWorkoutService: authenticatedContainer.currentWorkoutService,
                    selectedGroup: muscleGroup
                ) { [weak self] event in
                        switch event {
                        case let .openDetail(exercise):
                            self?.navigate(to: .exerciseDetail(for: exercise))
                        case .dismiss:
                            self?.popToRootSafely()
                        }
                }
            )
        case let .exerciseDetail(exercise):
            ExerciseDetailComponent(
                model: ExerciseDetailComponentModel(
                    currentWorkoutService: authenticatedContainer.currentWorkoutService,
                    exercise: exercise
                ) { [weak self] event in
                        switch event {
                        case .dismiss:
                            self?.popToRootSafely()
                        }
                }
            )
        case .categoryList:
            CategoryListComponent(
                model: CategoryListComponentModel(
                    exercisesService: authenticatedContainer.exercisesService,
                    currentWorkoutService: authenticatedContainer.currentWorkoutService
                ) { [weak self] event in
                        switch event {
                        case let .openExercises(for: muscleGroup):
                            self?.navigate(to: .exerciseList(for: muscleGroup))
                        case .dismiss:
                            self?.popToRootSafely()
                        }
                }
            )
        }
    }

    // MARK: - Private Methods

    // Pop one level at a time and yield between pops to let SwiftUI finish each
    // transition frame. A bulk root pop in this flow (search -> push detail -> dismiss)
    // can race with in-flight UI updates and leave blank/empty rendered views.
    private func popToRootSafely() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            while !self.path.isEmpty {
                self.pop()
                await Task.yield()
            }
        }
    }
}

extension WorkoutDetailFlowCoordinator {
    nonisolated enum Destination: CaseIdentifiable {
        case categoryList
        case exerciseList(for: MuscleGroup)
        case exerciseDetail(for: Exercise)

        var id: String {
            switch self {
            case .categoryList:
                "categoryList"
            case .exerciseList:
                "exerciseList"
            case .exerciseDetail:
                "exerciseDetail"
            }
        }
    }
}
