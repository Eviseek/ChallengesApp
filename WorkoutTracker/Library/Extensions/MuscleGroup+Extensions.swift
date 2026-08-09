//
//  Color+MuscleGroup.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 11.06.2026.
//

import Foundation

extension MuscleGroup {
    var sfSymbol: String {
        switch self {
        case .arms:
            "dumbbell.fill"
        case .back:
            "figure.strengthtraining.functional"
        case .cardio:
            "heart.fill"
        case .chest:
            "figure.strengthtraining.traditional"
        case .core:
            "figure.core.training"
        case .legs:
            "figure.run"
        case .other:
            "ellipsis.circle.fill"
        case .shoulders:
            "figure.wrestling"
        }
    }
}
