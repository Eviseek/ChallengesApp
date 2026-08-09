//
//  CurrentWorkoutService+LiveActivity.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 17.07.2026.
//

import ActivityKit
import OSLog

extension CurrentWorkoutServiceImpl {

    // Virtual start date: now minus active duration, so the Live Activity timer displays elapsed workout time.
    var startDate: Date {
        Date().addingTimeInterval(TimeInterval(-currentWorkout.duration))
    }

    func startActivity(startDate: Date) async {
        if liveActivityService.activity == nil {
            do {
                let state = WorkoutOverviewAttributes.ContentState(startDate: startDate, workoutName: currentWorkout.name)
                try await liveActivityService.start(with: state)
            } catch {
                logger.error("Start live activity error: \(error)")
            }
        } else if currentWorkout.state == .running {
            // Only update to "running" state if the workout is actually running.
            // Skipping this when paused prevents onAppear from clearing pausedAtSeconds.
            await updateActivity(startDate: startDate)
        }
    }

    func stopActivity() async {
        await liveActivityService.end()
    }

    // Preserves the existing state (notably activeExercise) instead of rebuilding it,
    // so resuming doesn't clear the active-exercise row from the Live Activity.
    func updateActivity(startDate: Date) async {
        do {
            var state = liveActivityService.activity?.content.state
                ?? WorkoutOverviewAttributes.ContentState(startDate: startDate, workoutName: currentWorkout.name)
            state.startDate = startDate
            state.workoutName = currentWorkout.name
            state.pausedAtSeconds = nil
            try await liveActivityService.update(with: state)
        } catch {
            logger.error("Issue resuming activity with error: \(error)")
        }
    }

    func updateActivity(activeSet: ExerciseSet) async {
        do {
            if var state = liveActivityService.activity?.content.state {
                state.activeExercise = activeSet.exercise.localizedName
                try await liveActivityService.update(with: state)
            }
        } catch {
            logger.error("Issue updating activity with error: \(error)")
        }
    }

    func pauseActivity(pausedSeconds: Int) async {
        do {
            if var state = liveActivityService.activity?.content.state {
                state.pausedAtSeconds = pausedSeconds
                try await liveActivityService.update(with: state)
            }
        } catch {
            logger.error("Issue pausing activity with error: \(error)")
        }
    }
}
