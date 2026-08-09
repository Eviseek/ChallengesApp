//  swiftlint:disable:this file_name
//  Summary.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 12.03.2026.
//

import Foundation

struct WorkoutSummary: Hashable, Equatable {
    let workoutName: String
    let formattedDate: String
    let exerciseSummaries: [ExerciseSetSummary]
}

struct ExerciseSetSummary: Hashable, Equatable {
    let exerciseName: String
    let totalSets: Int

    var formatted: String {
        "\(totalSets)x \(exerciseName)"
    }
}
