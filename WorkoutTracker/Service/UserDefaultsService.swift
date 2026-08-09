//
//  UserDefaultsService.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 23.03.2026.
//

import Foundation

protocol UserDefaultsService {
    func saveActiveChallengeId(_ challengeId: String)
    func getActiveChallengeId() -> String?
    func clearActiveChallengeId()
    func saveExercisesUpdatedDate(_ date: Date)
    func getExercisesUpdatedDate() -> Date?
}

final class UserDefaultsServiceImpl: UserDefaultsService {

    // MARK: - Private Properties

    private enum UserDefaultsKeys {
        static let challengeId = "challengeId"
        static let persistencyDate = "persistencyDate"
    }

    private let defaults = UserDefaults.standard

    // MARK: - Public Methods

    func saveActiveChallengeId(_ challengeId: String) {
        defaults.set(challengeId, forKey: UserDefaultsKeys.challengeId)
    }

    func getActiveChallengeId() -> String? {
        defaults.string(forKey: UserDefaultsKeys.challengeId)
    }

    func clearActiveChallengeId() {
        defaults.removeObject(forKey: UserDefaultsKeys.challengeId)
    }

    // MARK: Exercises Date

    func saveExercisesUpdatedDate(_ date: Date) {
        defaults.set(date, forKey: UserDefaultsKeys.persistencyDate)
    }

    func getExercisesUpdatedDate() -> Date? {
        defaults.object(forKey: UserDefaultsKeys.persistencyDate) as? Date
    }
}
