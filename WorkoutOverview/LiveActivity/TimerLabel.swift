//
//  TimerLabel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 27.03.2026.
//

import SwiftUI

struct TimerLabel: View {
    let state: WorkoutOverviewAttributes.ContentState
    var activeColor: Color = .Brand.electricGreen

    var body: some View {
        Group {
            if let seconds = state.pausedAtSeconds {
                Text(seconds.asTimeString())
                    .foregroundStyle(.white.opacity(0.5))
            } else {
                Text(timerInterval: state.startDate...Date.distantFuture, countsDown: false)
                    .foregroundStyle(activeColor)
            }
        }
        // Monospaced digits keep the timer from shifting width as it ticks.
        .monospacedDigit()
    }
}
