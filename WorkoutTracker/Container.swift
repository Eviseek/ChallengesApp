//
//  Container.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 04.03.2026.
//

final class Container {

    // MARK: - Public Properties

    private(set) var firebaseService: FirebaseService
    private(set) var authService: AuthService
    private(set) var userDefaultsService: UserDefaultsService
    private(set) var networkMonitorService: NetworkMonitorService

    // MARK: - Private Properties

    private var googleService: GoogleService

    // MARK: - Init

    init() {
        self.networkMonitorService = NetworkMonitorServiceImpl()
        self.firebaseService = ProductionFirebaseService(networkService: networkMonitorService)
        self.googleService = ProductionGoogleService()
        self.authService = ProductionAuthService(googleService: googleService)
        self.userDefaultsService = UserDefaultsServiceImpl()
    }
}
