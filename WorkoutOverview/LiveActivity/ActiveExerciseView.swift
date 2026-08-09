//
//  ActiveExerciseView.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 27.03.2026.
//

import SwiftUI

struct ActiveExerciseView: View {
    let state: WorkoutOverviewAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.extraMini) {
            if let activeExercise = state.activeExercise {
                Text(String(localized: "Current exercise"))
                    .font(.app(.caption2, .semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .textCase(.uppercase)
                Text(activeExercise)
                    .font(.app(.headline, .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            } else {
                Text("No active exercise")
                    .font(.app(.subheadline))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
