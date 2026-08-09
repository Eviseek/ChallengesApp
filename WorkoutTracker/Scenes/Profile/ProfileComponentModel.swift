//
//  LoginComponentModel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 18.03.2026.
//

import Foundation
import FuturedArchitecture
import Observation

protocol ProfileComponentModelProtocol: ComponentModel, Observable {
    var alertModel: AlertModel? { get set }
    var currentUser: AppUser { get }
    var workoutCount: Int { get }
    var timeTrainedValue: String { get }
    var timeTrainedLabel: String { get }
    var timeTrainedAccessibilityLabel: String { get }
    var uniqueExerciseCount: Int { get }
    var heaviestLift: String { get }

    func logOut()
}

@Observable
final class ProfileComponentModel: ProfileComponentModelProtocol {

    // MARK: - Public Properties

    let onEvent: (Event) -> Void
    var alertModel: AlertModel?

    var currentUser: AppUser {
        currentUserService.currentUser
    }

    var workoutCount: Int {
        workoutsService.workouts.count
    }

    var timeTrainedValue: String {
        let hours = workoutsService.workouts.totalDuration / 3_600
        return hours > 0 ? "\(hours)" : "\(workoutsService.workouts.totalDuration / 60)"
    }

    var timeTrainedLabel: String {
        let hours = workoutsService.workouts.totalDuration / 3_600
        return hours > 0 ? String(localized: "Hours Trained") : String(localized: "Minutes Trained")
    }

    var timeTrainedAccessibilityLabel: String {
        let hours = workoutsService.workouts.totalDuration / 3_600
        if hours > 0 {
            return LocalizedText.hours(hours)
        }
        return LocalizedText.minutes(workoutsService.workouts.totalDuration / 60)
    }

    var uniqueExerciseCount: Int {
        workoutsService.workouts.uniqueExerciseCount
    }

    var heaviestLift: String {
        guard let lift = workoutsService.workouts.heaviestLift else { return "—" }
        return "\(lift.formatted(.compactDecimal)) kg"
    }

    // MARK: - Private Properties

    private let workoutsService: WorkoutsService
    private let currentUserService: CurrentUserService
    private let authService: AuthService

    // MARK: - Init

    init(
        workoutsService: WorkoutsService,
        currentUserService: CurrentUserService,
        authService: AuthService,
        onEvent: @escaping (Event) -> Void
    ) {
        self.workoutsService = workoutsService
        self.currentUserService = currentUserService
        self.authService = authService
        self.onEvent = onEvent
    }

    // MARK: - Public Methods

    func logOut() {
        do {
            try authService.logOut()
        } catch {
            alertModel = AlertModel(error: .general)
        }
    }
}

extension ProfileComponentModel {
    enum Event {
        case destination
    }
}

#if DEBUG
@Observable
final class ProfileComponentModelMock: ProfileComponentModelProtocol {
    typealias Event = ProfileComponentModel.Event

    var onEvent: (Event) -> Void = { _ in }
    var alertModel: AlertModel?
    var currentUser: AppUser = AppUser(id: "1", displayName: "Test", email: "test@test.com", imageUrl: nil)
    var workoutCount: Int = 42
    var timeTrainedValue: String = "18"
    var timeTrainedLabel: String = "Hours Trained"
    var timeTrainedAccessibilityLabel: String = "18 hours"
    var uniqueExerciseCount: Int = 7
    var heaviestLift: String = ""

    func logOut() {}
}
#endif
