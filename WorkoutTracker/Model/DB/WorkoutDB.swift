//
//  WorkoutDB.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 20.02.2026.
//

import FirebaseFirestore
import Foundation

struct WorkoutDB: Codable {
    var id: String
    let userId: String
    let name: String
    let date: Date
    // Optional so documents written before this field existed still decode.
    let state: WorkoutState?
    let duration: Int       // seconds
    let exerciseSets: [ExerciseSetDB]
}
