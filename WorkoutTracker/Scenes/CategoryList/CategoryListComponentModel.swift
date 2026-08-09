//
//  CategoryListComponentModel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 06.03.2026.
//

import Foundation
import FuturedArchitecture
import Observation

enum SearchState {
    case idle, results, empty
}

protocol CategoryListComponentModelProtocol: ComponentModel {
    var searchText: String { get set }
    var searchState: SearchState { get }
    var filteredExercises: [Exercise] { get }
    var muscleGroups: [MuscleGroup] { get }

    func onGroupSelected(_ group: MuscleGroup)
    func onExerciseSelected(_ exercise: Exercise)
}

@Observable
final class CategoryListComponentModel: CategoryListComponentModelProtocol {

    // MARK: - Public Properties

    let onEvent: (Event) -> Void
    let muscleGroups: [MuscleGroup]
    var searchText: String = ""

    var searchState: SearchState {
        if searchText.isEmpty { return .idle }
        return filteredExercises.isEmpty ? .empty : .results
    }

    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return []
        } else {
            return exercisesService.exercises.filter { $0.localizedName.localizedStandardContains(searchText) }
        }
    }

    // MARK: - Private Properties

    private let exercisesService: ExercisesService
    private let currentWorkoutService: CurrentWorkoutService

    // MARK: - Init

    init(
        exercisesService: ExercisesService,
        currentWorkoutService: CurrentWorkoutService,
        onEvent: @escaping (Event) -> Void
    ) {
        self.exercisesService = exercisesService
        self.currentWorkoutService = currentWorkoutService
        self.onEvent = onEvent
        self.muscleGroups = MuscleGroup.allCases.sorted { $0.rawValue < $1.rawValue }
    }

    // MARK: - Public Methods

    func onGroupSelected(_ group: MuscleGroup) {
        onEvent(.openExercises(for: group))
    }

    func onExerciseSelected(_ exercise: Exercise) {
        currentWorkoutService.addSet(for: exercise)
        onEvent(.dismiss)
    }
}

extension CategoryListComponentModel {
    enum Event {
        case openExercises(for: MuscleGroup)
        case dismiss
    }
}

#if DEBUG
@Observable
final class CategoryListComponentModelMock: CategoryListComponentModelProtocol {
    typealias Event = CategoryListComponentModel.Event

    var onEvent: (Event) -> Void = { _ in }
    var searchText: String = ""
    var searchState: SearchState = .idle
    let filteredExercises: [Exercise] = []
    var muscleGroups: [MuscleGroup] = MuscleGroup.allCases

    func onAppear() async { }
    func onGroupSelected(_ group: MuscleGroup) { }
    func onExerciseSelected(_ exercise: Exercise) {}
}
#endif
