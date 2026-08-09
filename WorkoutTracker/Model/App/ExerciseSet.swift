//
//  WorkoutSet.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 20.02.2026.
//

import Foundation

nonisolated struct ExerciseSet: Hashable, Equatable, Codable {
    struct Values: Hashable, Equatable, Codable {
        var reps: Int?
        var weight: Double?
        var duration: Int?      // seconds
        var notes: String?
    }

    // Stable row identity so deleting a set does not reuse text field state across rows.
    var id: UUID = UUID()
    let exercise: Exercise
    var reps: Int?
    var weight: Double?
    var duration: Int?      // seconds
    var notes: String?
    var placeholder: Values?
}

// MARK: - Display Formatting

extension ExerciseSet {
    var formattedWeight: String? {
        weight.map { $0.formatted(.compactDecimal) }
    }

    var formattedDuration: String? {
        duration.map { String($0) }
    }

    // Placeholder shown in editable fields; falls back to "0" when the set has no prior value to suggest.
    var weightPlaceholder: String {
        placeholder?.weight.map { $0.formatted(.compactDecimal) } ?? "0"
    }

    var durationPlaceholder: String {
        placeholder?.duration.map { String($0) } ?? "0"
    }
}

extension ExerciseSet {
    var asExerciseSetDB: ExerciseSetDB {
        .init(
            exerciseId: exercise.id,
            reps: reps,
            weight: weight,
            duration: duration,
            notes: notes
        )
    }
}

extension [ExerciseSet] {
    var asExerciseSetDBArray: [ExerciseSetDB] {
        map(\.asExerciseSetDB)
    }

    /// Groups sets by their exercise, preserving first-appearance order.
    func groupedByExercise() -> [(exercise: Exercise, sets: [ExerciseSet])] {
        reduce(into: [(exercise: Exercise, sets: [ExerciseSet])]()) { result, set in
            if let index = result.firstIndex(where: { $0.exercise == set.exercise }) {
                result[index].sets.append(set)
            } else {
                result.append((exercise: set.exercise, sets: [set]))
            }
        }
    }
}
