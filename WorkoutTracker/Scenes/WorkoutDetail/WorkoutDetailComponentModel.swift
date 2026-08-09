//
//  WorkoutDetailComponentModel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 06.03.2026.
//

import Foundation
import FuturedArchitecture
import Observation
import SwiftUI

protocol WorkoutDetailComponentModelProtocol: ComponentModel, Observable {
    var alertModel: AlertModel? { get set }
    var workoutName: String { get set }
    var duration: Int { get }
    var isTimerRunning: Bool { get }
    var groupedExerciseSets: [(exercise: Exercise, sets: [ExerciseSet])] { get }

    func onAppear() async
    func addExerciseClicked()
    @discardableResult
    func addSet(for exercise: Exercise) -> UUID
    func updateSet(for exercise: Exercise, at setIndex: Int, reps: Int?, weight: Double?)
    func updateSet(for exercise: Exercise, at setIndex: Int, duration: Int?)
    func updateSet(for exercise: Exercise, at setIndex: Int, notes: String?)
    func deleteSet(for exercise: Exercise, at index: Int)
    func removeExercise(_ exercise: Exercise)
    func finishWorkout() async
    func deleteWorkout()
    func dismissWithNoSave()
    func pauseButtonClicked()
    func activeSetChanged(setID: UUID)
}

@Observable
final class WorkoutDetailComponentModel: WorkoutDetailComponentModelProtocol {

    // MARK: - Public Properties

    let onEvent: (Event) -> Void
    var alertModel: AlertModel?

    var isTimerRunning: Bool {
        workoutService.currentWorkout.state == .running
    }

    var workoutName: String {
        get { workoutService.currentWorkout.name }
        set { workoutService.updateWorkoutName(newValue) }
    }

    var duration: Int {
        workoutService.currentWorkout.duration
    }

    // Grouping is UI concern, no need to update the model itself
    var groupedExerciseSets: [(exercise: Exercise, sets: [ExerciseSet])] {
        workoutService.workoutSets.groupedByExercise()
    }

    // MARK: - Private Properties

    private let workoutService: CurrentWorkoutService

    // MARK: - Init

    init(
        workoutService: CurrentWorkoutService,
        onEvent: @escaping (Event) -> Void
    ) {
        self.workoutService = workoutService
        self.onEvent = onEvent
    }

    // MARK: - Public Methods

    func onAppear() async {
        workoutService.startWorkout(nil)
    }

    func addExerciseClicked() {
        onEvent(.openExerciseCategories)
    }

    @discardableResult
    func addSet(for exercise: Exercise) -> UUID {
        workoutService.addSet(for: exercise)
    }

    func updateSet(for exercise: Exercise, at setIndex: Int, reps: Int?, weight: Double?) {
        workoutService.updateSet(for: exercise, at: setIndex, reps: reps, weight: weight)
    }

    func updateSet(for exercise: Exercise, at setIndex: Int, duration: Int?) {
        workoutService.updateSet(for: exercise, at: setIndex, duration: duration)
    }

    func updateSet(for exercise: Exercise, at setIndex: Int, notes: String?) {
        workoutService.updateSet(for: exercise, at: setIndex, notes: notes)
    }

    func deleteSet(for exercise: Exercise, at index: Int) {
        workoutService.deleteSet(for: exercise, at: index)
    }

    func removeExercise(_ exercise: Exercise) {
        workoutService.removeExercise(exercise)
    }

    func finishWorkout() async {
        if workoutService.hasEmptySets {
            alertModel = emptySetAlertModel
        } else {
            await finishWorkoutAndDismiss()
        }
    }

    private func finishWorkoutAndDismiss() async {
        do {
            try await workoutService.finishWorkout()
            onEvent(.dismiss)
        } catch AppError.offline {
            alertModel = workoutPausedOfflineAlertModel
        } catch {
            alertModel = AlertModel(error: error)
        }
    }

    func deleteWorkout() {
        alertModel = AlertModel(
            title: String(localized: "Delete workout"),
            message: String(localized: .deleteWorkoutMessage),
            primaryAction: AlertModel.ButtonAction(title: String(localized: "Delete"), buttonRole: .destructive) { [weak self] in
                self?.workoutService.deleteWorkout()
                self?.onEvent(.dismiss)
            }
        )
    }

    func dismissWithNoSave() {
        workoutService.dismissWorkout()
        deleteWorkoutIfEmpty()
        onEvent(.dismiss)
    }

    func pauseButtonClicked() {
        if isTimerRunning {
            pauseWorkout()
        } else {
            resumeWorkout()
        }
    }

    func activeSetChanged(setID: UUID) {
        guard let set = workoutService.workoutSets.first(where: { $0.id == setID }) else { return }
        workoutService.updateActiveSet(set)
    }

    // MARK: - Private Methods

    private var emptySetAlertModel: AlertModel {
        AlertModel(
            title: String(localized: "Empty Sets"),
            message: String(localized: "Some of your sets are not filled out."),
            primaryAction: AlertModel.ButtonAction(title: String(localized: "Finish anyway"), buttonRole: .destructive) { [weak self] in
                Task { await self?.finishWorkoutAndDismiss() }
            },
            secondaryAction: AlertModel.ButtonAction(title: String(localized: "Cancel"), buttonRole: .cancel) { [weak self] in
                self?.alertModel = nil
            }
        )
    }

    private var workoutPausedOfflineAlertModel: AlertModel {
        AlertModel(
            title: String(localized: "Workout paused"),
            message: String(localized: "You're offline, so your workout was saved and paused. Finish it again once you're back online to save it."),
            primaryAction: AlertModel.ButtonAction(title: String(localized: "OK"), buttonRole: .cancel) { [weak self] in
                self?.onEvent(.dismiss)
            }
        )
    }

    private func resumeWorkout() {
        workoutService.resumeWorkout()
    }

    private func pauseWorkout() {
        workoutService.pauseWorkout()
    }

    private func deleteWorkoutIfEmpty() {
        guard workoutService.currentWorkout.exerciseSets.isEmpty else { return }
        workoutService.deleteWorkout()
    }
}

extension WorkoutDetailComponentModel {
    enum Event {
        case openExerciseCategories
        case dismiss
    }
}
