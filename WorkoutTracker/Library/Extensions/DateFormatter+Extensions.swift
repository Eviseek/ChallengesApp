//
//  DateFormatter+Extensions.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 16.03.2026.
//

import Foundation

extension DateFormatter {
    static let workoutDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d. M. yyyy"
        return formatter
    }()
}
