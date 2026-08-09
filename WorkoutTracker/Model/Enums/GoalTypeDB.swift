//
//  GoalTypeDB.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 03.03.2026.
//

import Foundation

nonisolated enum GoalTypeDB: String, Codable {
    case totalVolume   = "total_volume"
    case totalDuration = "total_duration"
    case workoutCount  = "workout_count"
}
