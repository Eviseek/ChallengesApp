//
//  Exercise.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 09.03.2026.
//

import Foundation

nonisolated struct Exercise: Hashable, Equatable, Sendable, Codable {
    var id: String
    let name: LocalizedString
    let muscleGroup: MuscleGroup
    let type: ExerciseType
    let description: LocalizedString?
}

extension Exercise {
    // Resolves the stored language maps to the active language for display.
    nonisolated var localizedName: String {
        name.localized
    }

    nonisolated var localizedDescription: String? {
        description?.localized
    }
}

#if DEBUG
extension Exercise {
    static let benchPress    = Exercise(id: "ex_bench_press", name: LocalizedString(["en": "Bench Press"]), muscleGroup: .chest, type: .reps, description: LocalizedString(["en": "Barbell flat bench press"]))
    static let inclinePress  = Exercise(id: "ex_incline_press", name: LocalizedString(["en": "Incline Press"]), muscleGroup: .chest, type: .reps, description: LocalizedString(["en": "Barbell incline bench press"]))
    static let deadlift      = Exercise(id: "ex_deadlift", name: LocalizedString(["en": "Deadlift"]), muscleGroup: .back, type: .reps, description: LocalizedString(["en": "Conventional barbell deadlift"]))
    static let pullUp        = Exercise(id: "ex_pull_up", name: LocalizedString(["en": "Pull Up"]), muscleGroup: .back, type: .reps, description: LocalizedString(["en": "Bodyweight pull up"]))
    static let squat         = Exercise(id: "ex_squat", name: LocalizedString(["en": "Squat"]), muscleGroup: .legs, type: .reps, description: LocalizedString(["en": "Barbell back squat"]))
    static let legPress      = Exercise(id: "ex_leg_press", name: LocalizedString(["en": "Leg Press"]), muscleGroup: .legs, type: .reps, description: LocalizedString(["en": "Machine leg press"]))
    static let overheadPress = Exercise(id: "ex_overhead_press", name: LocalizedString(["en": "Overhead Press"]), muscleGroup: .shoulders, type: .reps, description: LocalizedString(["en": "Barbell overhead press"]))
    static let bicepCurl     = Exercise(id: "ex_bicep_curl", name: LocalizedString(["en": "Bicep Curl"]), muscleGroup: .arms, type: .reps, description: LocalizedString(["en": "Dumbbell bicep curl"]))
    static let plank         = Exercise(id: "ex_plank", name: LocalizedString(["en": "Plank"]), muscleGroup: .core, type: .duration, description: LocalizedString(["en": "Standard forearm plank"]))
    static let treadmill     = Exercise(id: "ex_treadmill", name: LocalizedString(["en": "Treadmill"]), muscleGroup: .cardio, type: .duration, description: LocalizedString(["en": "Treadmill run"]))
}
#endif
