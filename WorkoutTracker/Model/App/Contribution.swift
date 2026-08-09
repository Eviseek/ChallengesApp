//
//  Contribution.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 03.03.2026.
//

import Foundation

nonisolated struct Contribution: Equatable {
    let id: String  // "{workoutId}_{exerciseId}" for exercise goals, workoutId for workout goals
    let workoutDate: Date
    let exerciseId: String?
    let exerciseName: String?
    let detail: String
    let contribution: Double
}
