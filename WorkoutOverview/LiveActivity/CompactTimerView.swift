//
//  CompactTimerView.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 27.03.2026.
//

import SwiftUI

struct CompactTimerView: View {
    let state: WorkoutOverviewAttributes.ContentState

    var body: some View {
        HStack(spacing: Metrics.mini) {
            Image(systemName: "dumbbell.fill")
                .foregroundStyle(state.stateColor)
            TimerLabel(state: state)
                .font(.app(.footnote, .semibold))
        }
    }
}
