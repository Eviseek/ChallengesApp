import Foundation

enum LocalizedText {
    static func participants(_ count: Int) -> String {
        localizedCount("%lld participants", count)
    }

    static func workouts(_ count: Int) -> String {
        localizedCount("%lld workouts", count)
    }

    static func exercises(_ count: Int) -> String {
        localizedCount("%lld exercises", count)
    }

    static func sets(_ count: Int) -> String {
        localizedCount("%lld sets", count)
    }

    static func points(_ count: Int) -> String {
        localizedCount("%lld points", count)
    }

    static func shortPoints(_ count: Int) -> String {
        localizedCount("%lld pts", count)
    }

    static func minutes(_ count: Int) -> String {
        localizedCount("%lld minutes", count)
    }

    static func hours(_ count: Int) -> String {
        localizedCount("%lld hours", count)
    }

    static func daysLeft(_ count: Int) -> String {
        localizedCount("%lld days left", count)
    }

    static func peopleJoined(_ count: Int) -> String {
        localizedCount("%lld people joined", count)
    }

    static func onlyParticipantsCompeted(_ count: Int) -> String {
        localizedCount("Only %lld participants competed.", count)
    }

    static func goal(_ value: String) -> String {
        String.localizedStringWithFormat(String(localized: "Goal: %@"), value)
    }

    static func goalDescription(type: String, exercises: String) -> String {
        String.localizedStringWithFormat(String(localized: "%@ on %@"), type, exercises)
    }

    static func totalVolume(unit: String) -> String {
        String.localizedStringWithFormat(String(localized: "Total volume in %@"), unit)
    }

    static func weight(value: Int, unit: String) -> String {
        String.localizedStringWithFormat(String(localized: "%lld %@"), value, unit)
    }

    static func prize(_ value: String) -> String {
        String.localizedStringWithFormat(String(localized: "Prize: %@"), value)
    }

    static func winner(_ value: String) -> String {
        String.localizedStringWithFormat(String(localized: "Winner: %@"), value)
    }

    static func rank(_ rank: Int, name: String, value: String) -> String {
        String.localizedStringWithFormat(String(localized: "Rank %lld, %@, %@"), rank, name, value)
    }

    static func nameAndStatus(name: String, status: String) -> String {
        String.localizedStringWithFormat(String(localized: "%@, %@"), name, status)
    }

    static func nameStatusDuration(name: String, status: String, duration: String) -> String {
        String.localizedStringWithFormat(String(localized: "%@, %@, %@"), name, status, duration)
    }

    static func workoutSummaryStats(duration: String, exercises: Int, sets: Int) -> String {
        String.localizedStringWithFormat(
            String(localized: "Duration %@, %@, %@"),
            duration,
            Self.exercises(exercises),
            Self.sets(sets)
        )
    }

    static func stat(value: String, label: String) -> String {
        String.localizedStringWithFormat(String(localized: "%@ %@"), value, label)
    }

    static func exercisesTried(_ count: Int) -> String {
        localizedCount("%lld exercises tried", count)
    }

    static func labelAndValue(label: String, value: String) -> String {
        String.localizedStringWithFormat(String(localized: "%@, %@"), label, value)
    }

    static func set(_ number: Int, isComplete: Bool) -> String {
        if isComplete {
            return String.localizedStringWithFormat(String(localized: "Set %lld, complete"), number)
        }
        return String.localizedStringWithFormat(String(localized: "Set %lld"), number)
    }

    static func weekSummary(label: String, workoutCount: Int) -> String {
        String.localizedStringWithFormat(String(localized: "%@, %@"), label, Self.workouts(workoutCount))
    }

    private static func localizedCount(_ key: String.LocalizationValue, _ count: Int) -> String {
        String.localizedStringWithFormat(String(localized: key), count)
    }
}
