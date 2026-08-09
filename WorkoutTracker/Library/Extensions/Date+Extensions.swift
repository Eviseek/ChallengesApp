//
//  Date+Extensions.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 12.03.2026.
//

import Foundation

extension Date {
    var workoutDisplayFormat: String {
        DateFormatter.workoutDisplay.string(from: self)
    }

    // "Jan 5 · Mon" eyebrow shown above each workout card (uppercased in the view).
    var workoutEyebrowFormat: String {
        let day = formatted(.dateTime.month(.abbreviated).day())
        let weekday = formatted(.dateTime.weekday(.abbreviated))
        return "\(day) · \(weekday)"
    }

    // Spelled-out "Monday, January 5" form read by VoiceOver; pass includingYear to append the year.
    func workoutAccessibilityFormat(includingYear: Bool = false) -> String {
        includingYear
            ? formatted(.dateTime.weekday(.wide).month(.wide).day().year())
            : formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    // Builds a "Jan 5 – Jan 11" / "Jan 28 – Feb 3" range covering the 7 days from this date.
    func weekRangeLabel(using calendar: Calendar = .current) -> String {
        let endDate = calendar.date(byAdding: .day, value: 6, to: self) ?? self
        let start = formatted(.dateTime.month(.abbreviated).day())
        let end = endDate.formatted(.dateTime.month(.abbreviated).day())
        return "\(start) – \(end)"
    }
}
