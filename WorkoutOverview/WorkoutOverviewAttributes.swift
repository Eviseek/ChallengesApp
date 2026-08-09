//
//  WorkoutOverviewAttributes.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 25.03.2026.
//

import ActivityKit
import SwiftUI

// `nonisolated` is required because the targets build with
// SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor. Without it, the conformance to
// ActivityAttributes is inferred as main actor-isolated, and ActivityKit's
// generic APIs (Activity.request/activities) need a nonisolated conformance.
nonisolated struct WorkoutOverviewAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var startDate: Date
        var workoutName: String
        var activeExercise: String?
        var pausedAtSeconds: Int?
    }

    var name: String
}

extension WorkoutOverviewAttributes.ContentState {
    var isPaused: Bool { pausedAtSeconds != nil }

    /// Accent for the running state — brand electric green while active, muted while paused.
    var stateColor: Color { isPaused ? .white.opacity(0.5) : Color.Brand.electricGreen }

    /// Accent for the running state — brand electric green while active, muted while paused.
    var iconColor: Color { isPaused ? .white.opacity(0.5) : .white.opacity(0.7) }
}
