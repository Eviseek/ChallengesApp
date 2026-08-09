//
//  ExerciseDetailComponentModel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 06.03.2026.
//

import FuturedArchitecture
import Observation

protocol ExerciseDetailComponentModelProtocol: ComponentModel {
    var exercise: Exercise { get }

    func onExerciseSelected()
}

@Observable
final class ExerciseDetailComponentModel: ExerciseDetailComponentModelProtocol {

    // MARK: - Public Properties

    let onEvent: (Event) -> Void
    let exercise: Exercise

    // MARK: - Private Properties

    private let currentWorkoutService: CurrentWorkoutService

    // MARK: - Init

    init(
        currentWorkoutService: CurrentWorkoutService,
        exercise: Exercise,
        onEvent: @escaping (Event) -> Void
    ) {
        self.currentWorkoutService = currentWorkoutService
        self.exercise = exercise
        self.onEvent = onEvent
    }

    // MARK: - Public Methods

    func onExerciseSelected() {
        currentWorkoutService.addSet(for: exercise)
        onEvent(.dismiss)
    }
}

extension ExerciseDetailComponentModel {
    enum Event {
        case dismiss
    }
}

#if DEBUG
@Observable
final class ExerciseDetailComponentModelMock: ExerciseDetailComponentModelProtocol {
    typealias Event = ExerciseDetailComponentModel.Event

    var onEvent: (Event) -> Void = { _ in }
    var exercise: Exercise = .benchPress

    func onExerciseSelected() { }
}
#endif
