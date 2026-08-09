//
//  LiveActivityService.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 26.03.2026.
//

@preconcurrency import ActivityKit
import Foundation

protocol LiveActivityService {
    var activity: Activity<WorkoutOverviewAttributes>? { get }

    func start(with contentState: WorkoutOverviewAttributes.ContentState) async throws
    func update(with contentState: WorkoutOverviewAttributes.ContentState) async throws
    func end() async
}

final class LiveActivityServiceImpl: LiveActivityService {

    // MARK: - Public Properties

    private(set) var activity: Activity<WorkoutOverviewAttributes>?

    init() {
        // On cold launch after the OS killed the app, the Live Activity can still
        // be running on the lock screen. Activity.activities lists all currently
        // active activities for this app, so we reconnect to the existing one here.
        // Without this, activity would be nil and syncTimerFromLiveActivityIfNeeded()
        // would have no startDate to read from, leaving the restored workout timer stale.
        self.activity = Activity<WorkoutOverviewAttributes>.activities.first
    }

    // MARK: - Public Methods

    func start(with contentState: WorkoutOverviewAttributes.ContentState) async throws {
        guard activity == nil else { return }
        let attributes = WorkoutOverviewAttributes(name: "Live Activity")
        let content = ActivityContent(
            state: contentState,
            staleDate: nil
        )
        activity = try Activity<WorkoutOverviewAttributes>.request(attributes: attributes, content: content, pushType: nil)
    }

    func update(with contentState: WorkoutOverviewAttributes.ContentState) async throws {
        guard activity != nil else { return }
        let content = ActivityContent(
            state: contentState,
            staleDate: nil
        )
        await activity?.update(content)
    }

    func end() async {
        guard let currentActivity = activity else { return }
        activity = nil
        await currentActivity.end(nil, dismissalPolicy: .immediate)
    }
}
