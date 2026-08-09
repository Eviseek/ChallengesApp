//
//  WorkoutOverviewLiveActivity.swift
//  WorkoutOverview
//
//  Created by Eva Chlpikova on 25.03.2026.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct WorkoutOverviewLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutOverviewAttributes.self) { context in
            NotificationView(state: context.state)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    CompactTimerView(state: context.state)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    WorkoutStatusBadge(state: context.state)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ActiveExerciseView(state: context.state)
                }
            } compactLeading: {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(context.state.iconColor)
            } compactTrailing: {
                TimerLabel(state: context.state, activeColor: context.state.iconColor)
                    .font(.app(.footnote, .semibold))
            } minimal: {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(context.state.iconColor)
            }
            .keylineTint(context.state.stateColor)
        }
    }
}
