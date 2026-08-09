//
//  ContributionDB.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 03.03.2026.
//

import FirebaseFirestore
import Foundation

struct ContributionDB: Codable {
    let workoutDate: Timestamp
    let exerciseId: String?
    let exerciseName: String?
    let detail: String
    let contribution: Double
}

extension ContributionDB {
    init(from contribution: Contribution) {
        self.workoutDate = Timestamp(date: contribution.workoutDate)
        self.exerciseId = contribution.exerciseId
        self.exerciseName = contribution.exerciseName
        self.detail = contribution.detail
        self.contribution = contribution.contribution
    }
}
