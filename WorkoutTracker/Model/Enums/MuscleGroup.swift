//
//  MuscleGroup.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 03.03.2026.
//

import Foundation

enum MuscleGroup: String, Codable, CaseIterable, Equatable {
    case chest = "Chest"
    case back = "Back"
    case legs = "Legs"
    case shoulders = "Shoulders"
    case arms = "Arms"
    case core = "Core"
    case cardio = "Cardio"
    case other = "Other"
}

extension MuscleGroup {
    var displayName: String {
        switch self {
        case .chest:
            String(localized: "Chest")
        case .back:
            String(localized: "Back")
        case .legs:
            String(localized: "Legs")
        case .shoulders:
            String(localized: "Shoulders")
        case .arms:
            String(localized: "Arms")
        case .core:
            String(localized: "Core")
        case .cardio:
            String(localized: "Cardio")
        case .other:
            String(localized: "Other")
        }
    }
}
