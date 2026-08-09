//
//  WorkoutListFlowCoordinator.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 05.03.2026.
//

import FuturedArchitecture
import SwiftUI

@Observable
final class WorkoutListFlowCoordinator: @MainActor NavigationStackCoordinator {

    // MARK: - Public Properties

    var path: [Destination] = []
    var modalCover: ModalCoverModel<Destination>?

    // MARK: - Private Properties

    private var authenticatedContainer: AuthenticatedContainer

    // MARK: - Init

    init(authenticatedContainer: AuthenticatedContainer) {
        self.authenticatedContainer = authenticatedContainer
    }

    // MARK: - Public Methods

    static func rootView(with instance: WorkoutListFlowCoordinator) -> some View {
        NavigationStackFlow(coordinator: instance) {
            WorkoutListComponent(
                model: WorkoutListComponentModel(
                    workoutsService: instance.authenticatedContainer.workoutsService,
                    exercisesService: instance.authenticatedContainer.exercisesService,
                    currentWorkoutService: instance.authenticatedContainer.currentWorkoutService,
                    challengeService: instance.authenticatedContainer.challengeService) { [weak instance] event in
                    switch event {
                    case .workoutDetail:
                        instance?.present(modal: .workoutDetail, type: .fullscreenCover)
                    case let .workoutSummary(workout):
                        instance?.navigate(to: .workoutSummary(workout))
                    }
                }
            )
        }
    }

    @ViewBuilder
    func scene(for destination: Destination) -> some View {
        switch destination {
        case .workoutDetail:
            WorkoutDetailFlowCoordinator.rootView(
                with: .init(authenticatedContainer: authenticatedContainer) { [weak self] event in
                    switch event {
                    case .dismiss:
                        self?.dismissModal()
                    }
                }
            )
        case let .workoutSummary(workout):
            WorkoutSummaryComponent(
                model: WorkoutSummaryComponentModel(
                    workout: workout,
                    workoutsService: authenticatedContainer.workoutsService,
                    workoutService: authenticatedContainer.currentWorkoutService) { [weak self] event in
                        switch event {
                        case .startRepeatedWorkout:
                            self?.pop()
                            self?.present(modal: .workoutDetail, type: .fullscreenCover)
                        }
                }
            )
        }
    }
}

extension WorkoutListFlowCoordinator {
    nonisolated enum Destination: CaseIdentifiable {
        case workoutDetail
        case workoutSummary(Workout)

        var id: String {
            switch self {
            case .workoutDetail:
                "workoutDetail"
            case .workoutSummary:
                "workoutSummary"
            }
        }
    }
}
