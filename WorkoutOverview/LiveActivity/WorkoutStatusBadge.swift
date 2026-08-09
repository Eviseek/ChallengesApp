//
//  WorkoutStatusBadge.swift
//  WorkoutOverview
//
//  Created by Eva Chlpikova on 17.07.2026.
//

import SwiftUI

struct WorkoutStatusBadge: View {
    let state: WorkoutOverviewAttributes.ContentState

    var body: some View {
        HStack(spacing: Metrics.extraSmall) {
            Circle()
                .fill(state.stateColor)
                .frame(width: Metrics.extraSmall, height: Metrics.extraSmall)
            Text(state.isPaused ? "Paused" : "In progress")
                .font(.app(.caption, .semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}
