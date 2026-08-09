//
//  GoalDB.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 03.03.2026.
//

import Foundation

// `exerciseIds` is the only exercise reference stored: names are resolved from the local
// catalog at read time so they follow the active language.
struct GoalDB: Codable {
    let type: GoalTypeDB
    let exerciseIds: [String] // empty if not needed
    let unit: GoalUnit
}

extension GoalDB {
    init(from goal: Goal) {
        let (dbType, dbUnit): (GoalTypeDB, GoalUnit) = switch goal.type {
        case .totalVolume(let unit):
            (.totalVolume, unit == .lbs ? .lbs : .kg)
        case .totalDuration:
            (.totalDuration, .seconds)
        case .workoutCount:
            (.workoutCount, .count)
        }
        self.init(
            type: dbType,
            exerciseIds: goal.exercises.map(\.id),
            unit: dbUnit
        )
    }
}
