//
//  AuthenticatedContainer.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 19.03.2026.
//

import Foundation
import FuturedArchitecture

final class AuthenticatedContainer {

    // MARK: - Public Properties

    let dataCache: DataCache<DataCacheModel>
    var networkMonitorService: NetworkMonitorService
    var firebaseService: FirebaseService
    var authService: AuthService
    var userDefaultsService: UserDefaultsService
    var currentWorkoutService: CurrentWorkoutService
    var challengeService: ChallengeService
    var liveActivityService: LiveActivityService
    var persistenceService: PersistenceService
    var exercisesService: ExercisesService
    var workoutsService: WorkoutsService
    var currentUserService: CurrentUserService

    // MARK: - Init

    init(
        firebaseService: FirebaseService,
        networkMonitorService: NetworkMonitorService,
        authService: AuthService,
        userDefaultsService: UserDefaultsService,
        user: AppUser
    ) throws {
        self.dataCache = DataCache(value: DataCacheModel(currentUser: user))
        self.networkMonitorService = networkMonitorService
        self.firebaseService = firebaseService
        self.authService = authService
        self.userDefaultsService = userDefaultsService
        self.liveActivityService = LiveActivityServiceImpl()

        self.challengeService = ChallengeServiceImpl(dataCache: dataCache, defaultsService: userDefaultsService, firebaseService: firebaseService)
        let (persistenceService, updateStream): (PersistenceService, AsyncStream<PersistenceServiceEvent>)
        do {
            (persistenceService, updateStream) = try PersistenceServiceImpl.makeServiceWithContainerListener()
        } catch {
            (persistenceService, updateStream) = try PersistenceServiceImpl.makeServiceWithContainerListener(inMemory: true)
        }
        self.persistenceService = persistenceService
        self.currentWorkoutService = CurrentWorkoutServiceImpl(dataCache: dataCache, liveActivityService: liveActivityService, firebaseService: firebaseService, persistenceService: persistenceService, contributionsResource: ContributionsResource())
        self.exercisesService = ExercisesServiceImpl(dataCache: dataCache, userDefaultsService: userDefaultsService, firebaseService: firebaseService, persistenceService: persistenceService, updateStream: updateStream)
        self.workoutsService = WorkoutsServiceImpl(dataCache: dataCache, firebaseService: firebaseService, networkMonitorService: networkMonitorService, persistenceService: persistenceService)
        self.currentUserService = CurrentUserServiceImpl(dataCache: dataCache)
    }

    // MARK: - Public Methods

    // Wipes the locally cached data of the signed-out user. The exercise catalog is shared across accounts, so it stays cached.
    func clearUserData() async {
        await currentWorkoutService.endSession()
        await persistenceService.deleteAllWorkouts()
    }
}
