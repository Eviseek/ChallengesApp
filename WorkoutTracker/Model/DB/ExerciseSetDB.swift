//
//  ExerciseSetDB.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 20.02.2026.
//

import FirebaseFirestore
import Foundation

struct ExerciseSetDB: Codable {
    var exerciseId: String
    let reps: Int?
    let weight: Double?
    let duration: Int?
    let notes: String?
}

extension ExerciseSetDB {
    func asExerciseSet(exercise: Exercise) -> ExerciseSet {
        .init(
            exercise: exercise,
            reps: reps,
            weight: weight,
            duration: duration,
            notes: notes
        )
    }
}
