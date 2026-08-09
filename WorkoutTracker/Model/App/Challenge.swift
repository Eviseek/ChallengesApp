//
//  Challenge.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 03.03.2026.
//

import FirebaseFirestore
import Foundation

nonisolated struct Challenge: Equatable {
    let id: String
    let creatorId: String
    let title: LocalizedString
    let description: LocalizedString?
    let prize: LocalizedString?
    let start: Date
    let end: Date
    let goal: Goal
    let createdAt: Date
    var participants: [Participant] = []

    var isActive: Bool {
        let now = Date()
        return start <= now && now <= end
    }

    var isPast: Bool {
        Date() > end
    }
}

extension Challenge {
    // Resolves the stored language maps to the active language for display.
    nonisolated var localizedTitle: String {
        title.localized
    }

    nonisolated var localizedDescription: String? {
        description?.localized
    }

    nonisolated var localizedPrize: String? {
        prize?.localized
    }
}

extension Challenge {
    // MainActor-isolated (via extension default isolation) so it can use `LocalizedText`, which the nonisolated struct body can't.
    var daysLeftLabel: String {
        let days = max(0, Calendar.current.dateComponents([.day], from: Date(), to: end).day ?? 0)
        return switch days {
        case 0:
            String(localized: "Ends today")
        default:
            LocalizedText.daysLeft(days)
        }
    }
}

extension Challenge {
    init?(from db: ChallengeDB, exercises: [Exercise]) { // swiftlint:disable:this identifier_name
        guard let id = db.id else { return nil }
        self.id = id
        self.creatorId = db.creatorId
        self.title = db.title.localizedString
        self.description = db.description?.localizedString
        self.prize = db.prize?.localizedString
        self.start = db.start.dateValue()
        self.end = db.end.dateValue()
        self.goal = Goal(from: db.goal, exercises: exercises)
        self.createdAt = db.createdAt.dateValue()
    }
}

// MARK: Display

extension Challenge {
    // Abbreviated date range: "Oct 1 – Oct 30". Shown as the detail-screen eyebrow (uppercased in the view).
    var displayDateRange: String {
        let start = start.formatted(.dateTime.month(.abbreviated).day())
        let end = end.formatted(.dateTime.month(.abbreviated).day())
        return "\(start) – \(end)"
    }

    // "Ended · Oct 30" eyebrow shown on finished-challenge cards (uppercased in the view).
    var endedEyebrow: String {
        "\(String(localized: "Ended")) · \(end.formatted(.dateTime.month(.abbreviated).day()))"
    }
}

// MARK: Accessibility

extension Challenge {
    // Wide-format date range: "October 1 – October 30". Reused by list/card labels and standalone date elements.
    var accessibilityDateRange: String {
        let start = start.formatted(.dateTime.month(.wide).day())
        let end = end.formatted(.dateTime.month(.wide).day())
        return "\(start) – \(end)"
    }

    // Used by ChallengeCard (card — shows "Ended [date]")
    var accessibilityLabelEnded: String {
        let endDate = end.formatted(.dateTime.month(.wide).day())
        let dateDescription = String.localizedStringWithFormat(String(localized: "Ended %@"), endDate)
        return accessibilityLabel(dateDescription: dateDescription)
    }

    private func accessibilityLabel(dateDescription: String) -> String {
        var parts = [localizedTitle, dateDescription, goal.description]
        if !participants.isEmpty {
            parts.append(LocalizedText.participants(participants.count))
        }
        if let prize = localizedPrize { parts.append(LocalizedText.prize(prize)) }
        if let winner = participants.first {
            let winnerName = winner.isCurrentUser ? String(localized: "You") : winner.displayName
            parts.append(LocalizedText.winner(winnerName))
        }
        return parts.joined(separator: ", ")
    }
}

// MARK: Testing data

#if DEBUG
extension Challenge {
    static let mock = Challenge(
        id: "challenge_1",
        creatorId: "user_1",
        title: LocalizedString(["en": "30-Day Push-Up Challenge"]),
        description: LocalizedString(["en": "Push your limits with daily push-ups for 30 days."]),
        prize: LocalizedString(["en": "Nike Gift Card $50"]),
        start: Date().addingTimeInterval(-86_400),  // yesterday
        end: Date().addingTimeInterval(86_400 * 29), // 29 days from now
        goal: Goal(
            type: .totalVolume(unit: .kg),
            exercises: [.benchPress]
        ),
        createdAt: Date().addingTimeInterval(-86_400 * 2)
    )

    static let mockFinished = Challenge(
        id: "challenge_finished_1",
        creatorId: "user_1",
        title: LocalizedString(["en": "Summer Shred Challenge"]),
        description: LocalizedString(["en": "30 days of daily push-ups."]),
        prize: LocalizedString(["en": "Nike Gift Card $50"]),
        start: Date().addingTimeInterval(-86_400 * 31),
        end: Date().addingTimeInterval(-86_400),
        goal: Goal(type: .totalVolume(unit: .kg), exercises: [.benchPress]),
        createdAt: Date().addingTimeInterval(-86_400 * 33),
        participants: [
            Participant(id: "p1", displayName: "Lucas Hill", value: 120, contributions: [], isCurrentUser: false),
            Participant(id: "p2", displayName: "Sofia Novak", value: 110, contributions: [], isCurrentUser: false),
            Participant(id: "p3", displayName: "Tom Becker", value: 95, contributions: [], isCurrentUser: false),
            Participant(id: "p4", displayName: "Jana Horák", value: 88, contributions: [], isCurrentUser: false),
            Participant(id: "p5", displayName: "Eva Chlpikova", value: 87, contributions: [], isCurrentUser: true),
            Participant(id: "p6", displayName: "Marek Varga", value: 60, contributions: [], isCurrentUser: false),
            Participant(id: "p7", displayName: "Marek Varga", value: 60, contributions: [], isCurrentUser: false),
            Participant(id: "p8", displayName: "Marek Varga", value: 60, contributions: [], isCurrentUser: false),
            Participant(id: "p9", displayName: "Marek Varga", value: 60, contributions: [], isCurrentUser: false),
            Participant(id: "p10", displayName: "Marek Varga", value: 60, contributions: [], isCurrentUser: false),
            Participant(id: "p11", displayName: "Marek Varga", value: 60, contributions: [], isCurrentUser: false),
            Participant(id: "p12", displayName: "Marek Varga", value: 60, contributions: [], isCurrentUser: false),
            Participant(id: "p13", displayName: "Marek Varga", value: 60, contributions: [], isCurrentUser: false)
        ]
    )
}
#endif
