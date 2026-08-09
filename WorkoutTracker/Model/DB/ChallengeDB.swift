//
//  ChallengeDB.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 03.03.2026.
//

import FirebaseFirestore
import Foundation

struct ChallengeDB: Codable {
    @DocumentID var id: String?
    let creatorId: String
    let title: LocalizedStringDB
    let description: LocalizedStringDB?
    let prize: LocalizedStringDB?
    let start: Timestamp
    let end: Timestamp
    let goal: GoalDB
    let createdAt: Timestamp
}
