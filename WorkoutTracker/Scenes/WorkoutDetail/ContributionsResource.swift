//
//  ContributionsResource.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 10.04.2026.
//

import Foundation

protocol ContributionsResourceProtocol {
    func contributions(for goal: Goal, workout: Workout) -> [Contribution]
}

struct ContributionsResource: ContributionsResourceProtocol {

    func contributions(for goal: Goal, workout: Workout) -> [Contribution] {
        switch goal.type {
        case .totalDuration:
            return [contribution(value: Double(workout.duration), workout: workout)]
        case .workoutCount:
            return [contribution(value: 1.0, workout: workout)]
        case .totalVolume(let unit):
            return exercises(for: goal, workout: workout)
                .compactMap { volumeContribution(for: $0, unit: unit, workout: workout) }
        }
    }

    private func exerciseSets(for exercise: Exercise, workout: Workout) -> [ExerciseSet] {
        workout.exerciseSets.filter { $0.exercise.id == exercise.id }
    }

    private func exercises(for goal: Goal, workout: Workout) -> [Exercise] {
        goal.exercises
            .filter { !exerciseSets(for: $0, workout: workout).isEmpty }
    }

    private func volumeContribution(for exercise: Exercise, unit: Goal.WeightUnit, workout: Workout) -> Contribution? {
        exerciseSets(for: exercise, workout: workout)
            .compactMap { set -> (ExerciseSet, Double)? in
                guard let weight = set.weight, let reps = set.reps else { return nil }
                return (set, weight * Double(reps))
            }
            .max { $0.1 < $1.1 }
            .map { set, volume in
                guard let reps = set.reps else { return contribution(value: volume, workout: workout, exerciseId: exercise.id, exerciseName: exercise.localizedName) }
                return contribution(
                    value: volume,
                    workout: workout,
                    exerciseId: exercise.id,
                    exerciseName: exercise.localizedName,
                    detail: "\(Int(volume))\(unit), \(reps) reps"
                )
            }
    }

    private func contribution(value: Double, workout: Workout, exerciseId: String? = nil, exerciseName: String? = nil, detail: String = "") -> Contribution {
        let id = [workout.id, exerciseId].compactMap { $0 }.joined(separator: "_")

        return Contribution(
            id: id,
            workoutDate: workout.date,
            exerciseId: exerciseId,
            exerciseName: exerciseName,
            detail: detail,
            contribution: value
        )
    }
}
