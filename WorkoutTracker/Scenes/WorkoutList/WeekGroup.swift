//
//  WorkoutWeekGrouping.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 15.07.2026.
//

import Foundation

enum WorkoutSortOrder {
    case newestFirst
    case oldestFirst
}

struct WeekGroup: Identifiable {
    let id: Date
    let label: String
    let isCurrent: Bool
    let workouts: [Workout]
}

extension [Workout] {
    // Sorts the workouts and buckets them into week sections with display-ready labels.
    func groupedByWeek(
        sortOrder: WorkoutSortOrder,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [WeekGroup] {
        let sorted = sorted { sortOrder == .newestFirst ? $0.date > $1.date : $0.date < $1.date }
        let byWeekStart = Dictionary(grouping: sorted) { workout in
            calendar.dateInterval(of: .weekOfYear, for: workout.date)?.start ?? workout.date
        }
        return byWeekStart.keys
            .sorted { sortOrder == .newestFirst ? $0 > $1 : $0 < $1 }
            .map { weekStart in
                let isCurrent = calendar.isDate(weekStart, equalTo: now, toGranularity: .weekOfYear)
                return WeekGroup(
                    id: weekStart,
                    label: isCurrent ? String(localized: "This week") : weekStart.weekRangeLabel(using: calendar),
                    isCurrent: isCurrent,
                    workouts: byWeekStart[weekStart, default: []]
                )
            }
    }
}
