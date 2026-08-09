//
//  Participant.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 03.03.2026.
//

import FirebaseFirestore
import Foundation

nonisolated struct Participant: Equatable {
    var id: String
    let displayName: String
    let value: Double
    let contributions: [Contribution]
    var isCurrentUser: Bool
}

struct LeaderboardEntry: Identifiable {
    let rank: Int
    let participant: Participant

    var id: String { participant.id }
}

extension [Participant] {
    // Participants ordered by value descending, each paired with its 1-based rank.
    // `onlyScoring` drops zero-value participants (leaderboards); pass false to keep everyone (podiums/final results).
    func ranked(onlyScoring: Bool = true) -> [LeaderboardEntry] {
        let base = onlyScoring ? filter { $0.value > 0 } : self
        return base
            .sorted { $0.value > $1.value }
            .enumerated()
            .map { LeaderboardEntry(rank: $0.offset + 1, participant: $0.element) }
    }
}

extension Participant {
    init?(from db: ParticipantDB, currentUserId: String) { // swiftlint:disable:this identifier_name
        guard let id = db.id else {
            assertionFailure("Firebase did not provide an ID for a document")
            return nil
        }
        self.id = id
        self.displayName = db.displayName
        self.value = db.value
        self.contributions = db.contributions.map { key, value in
            Contribution(
                id: key,
                workoutDate: value.workoutDate.dateValue(),
                exerciseId: value.exerciseId,
                exerciseName: value.exerciseName,
                detail: value.detail,
                contribution: value.contribution
            )
        }
        .sorted { $0.workoutDate > $1.workoutDate }
        self.isCurrentUser = id == currentUserId
    }
}
