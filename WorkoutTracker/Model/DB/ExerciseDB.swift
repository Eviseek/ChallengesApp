//
//  ExerciseDB.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 03.03.2026.
//

import FirebaseFirestore
import Foundation

struct ExerciseDB: Codable, Hashable, Equatable {
    @DocumentID var id: String?
    let name: LocalizedStringDB
    let muscleGroup: MuscleGroup
    let type: ExerciseType
    let description: LocalizedStringDB?
}
