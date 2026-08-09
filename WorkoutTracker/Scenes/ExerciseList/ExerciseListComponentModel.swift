//
//  ExerciseListComponentModel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 06.03.2026.
//

import Foundation
import FuturedArchitecture
import Observation

protocol ExerciseListComponentModelProtocol: ComponentModel {
    var navigationTitle: String { get }
    var searchText: String { get set }
    var filteredExercises: [Exercise] { get }

    func onExerciseSelected(_ exercise: Exercise)
    func onInfoButtonClicked(for exercise: Exercise)
}

@Observable
final class ExerciseListComponentModel: ExerciseListComponentModelProtocol {

    // MARK: - Public Properties

    let onEvent: (Event) -> Void
    var searchText: String = ""

    var navigationTitle: String {
        selectedGroup.displayName
    }

    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercisesService.exercises.filter { $0.muscleGroup == selectedGroup }
        }
        return exercisesService.exercises.filter {
            $0.muscleGroup == selectedGroup && $0.localizedName.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Private Properties

    private let exercisesService: ExercisesService
    private let currentWorkoutService: CurrentWorkoutService
    private let selectedGroup: MuscleGroup

    // MARK: - Init

    init(
        exercisesService: ExercisesService,
        currentWorkoutService: CurrentWorkoutService,
        selectedGroup: MuscleGroup,
        onEvent: @escaping (Event) -> Void
    ) {
        self.exercisesService = exercisesService
        self.currentWorkoutService = currentWorkoutService
        self.selectedGroup = selectedGroup
        self.onEvent = onEvent
    }

    // MARK: - Public Methods

    func onExerciseSelected(_ exercise: Exercise) {
        currentWorkoutService.addSet(for: exercise)
        onEvent(.dismiss)
    }

    func onInfoButtonClicked(for exercise: Exercise) {
        onEvent(.openDetail(for: exercise))
    }
}

extension ExerciseListComponentModel {
    enum Event {
        case openDetail(for: Exercise)
        case dismiss
    }
}

#if DEBUG
@Observable
final class ExerciseListComponentModelMock: ExerciseListComponentModelProtocol {
    typealias Event = ExerciseListComponentModel.Event

    var onEvent: (Event) -> Void = { _ in }
    var navigationTitle: String = MuscleGroup.chest.rawValue
    var searchText: String = ""
    var filteredExercises: [Exercise] = [.benchPress, .bicepCurl, .deadlift]

    func onExerciseSelected(_ exercise: Exercise) { }
    func onInfoButtonClicked(for exercise: Exercise) { }
}
#endif
