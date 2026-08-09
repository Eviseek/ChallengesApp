//
//  Int+Extensions.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 10.03.2026.
//

import Foundation

private let workoutAccessibleDurationFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.unitsStyle = .full
    formatter.zeroFormattingBehavior = .dropAll
    return formatter
}()

extension Int {
    /// Converts an integer representing seconds into a HH:MM:SS format or MM:SS format
    func asTimeString() -> String {
        let hours = self / 3_600
        let minutes = (self % 3_600) / 60
        let seconds = self % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    /// Compact "1h 30m" / "45m" / "< 1m" duration label from seconds, shown on the workout card.
    func asWorkoutDurationLabel() -> String {
        guard self > 0 else { return "–" }
        let hours = self / 3_600
        let minutes = (self % 3_600) / 60
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        }
        return minutes > 0 ? "\(minutes)m" : "< 1m"
    }

    /// Spelled-out duration read by VoiceOver; empty when there is no duration to announce.
    func asAccessibleDurationLabel() -> String {
        guard self > 0 else { return "" }
        guard self >= 60 else { return String(localized: "less than 1 minute") }
        return workoutAccessibleDurationFormatter.string(from: TimeInterval(self)) ?? asWorkoutDurationLabel()
    }
}
