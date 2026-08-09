//
//  ParticipantDB.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 03.03.2026.
//

import FirebaseFirestore
import Foundation

struct ParticipantDB: Codable {
    @DocumentID var id: String?  // userId
    let displayName: String
    let challengeId: String
    let value: Double
    let contributions: [String: ContributionDB]

    init(displayName: String, challengeId: String, value: Double, contributions: [String: ContributionDB]) {
        self.displayName = displayName
        self.challengeId = challengeId
        self.value = value
        self.contributions = contributions
    }
}
