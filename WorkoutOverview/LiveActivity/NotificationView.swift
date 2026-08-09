//
//  NotificationView.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 27.03.2026.
//

import SwiftUI
import WidgetKit

struct NotificationView: View {
    let state: WorkoutOverviewAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.small) {
            header
            timer
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .activityBackgroundTint(Color.Brand.processBlack)
        .activitySystemActionForegroundColor(Color.Brand.electricGreen)
    }

    private var header: some View {
        VStack(alignment: .leading) {
            WorkoutStatusBadge(state: state)
            Text(state.workoutName)
                .font(.Archivo.title)
                .foregroundStyle(.white)
                .lineLimit(1)
        }
    }

    private var timer: some View {
        // Fixed-size hero number: a Live Activity has a constrained, non-scrolling layout.
        TimerLabel(state: state)
            .font(.appFixed(size: 44, weight: .bold))
    }
}
