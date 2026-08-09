//
//  ExerciseType.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 03.03.2026.
//

import Foundation

enum ExerciseType: String, Codable, Equatable {
    case reps = "Reps"
    case duration = "Duration"
}

extension ExerciseType {
    var displayName: String {
        switch self {
        case .reps:
            String(localized: "Reps")
        case .duration:
            String(localized: "Duration")
        }
    }
}
