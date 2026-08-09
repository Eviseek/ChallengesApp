//
//  WorkoutModel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 29.06.2026.
//

import Foundation
import SwiftData

@Model
class WorkoutModel {
    @Attribute(.unique)
    var id: String
    var name: String
    var date: Date
    var state: WorkoutState
    var duration: Int       // seconds
    var exerciseSets: [ExerciseSet]

    var isCurrent: Bool

    init(id: String, name: String, date: Date, state: WorkoutState, duration: Int, exerciseSets: [ExerciseSet], isCurrent: Bool = false) {
        self.id = id
        self.name = name
        self.date = date
        self.state = state
        self.duration = duration
        self.exerciseSets = exerciseSets
        self.isCurrent = isCurrent
    }
}
