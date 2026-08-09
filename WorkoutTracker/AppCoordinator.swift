//
//  AppCoordinator.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 04.03.2026.
//

import FirebaseAuth
import OSLog
import SwiftUI

@Observable
final class AppCoordinator {

    // MARK: - Public Properties

    var appState: AppState = .splash
    var loginCoordinator: LoginFlowCoordinator
    var tabCoordinator: TabViewFlowCoordinator?

    // MARK: - Private Properties

    private let logger = Logger(subsystem: "app.eviseek.workoutTracker", category: "AppCoordinator")
    private var container: Container
    private var authenticatedContainer: AuthenticatedContainer?

    // MARK: - Init

    init(container: Container) {
        self.container = container
        self.loginCoordinator = LoginFlowCoordinator(container: container)
        observeAuthState()
    }

    // MARK: - Private Methods

    private func observeAuthState() {
        // No need to store and manually cancel since AppCoordinator is deallocated only on whole app termination.
        Task { @MainActor [weak self] in
            guard let self else { return } // swiftlint:disable:this conditional_returns_on_newline
            for await state in container.authService.stateStream {
                switch state {
                case .authenticated:
                    await setupAuthenticatedSession()
                case .nonauthenticated:
                    await tearDownAuthenticatedSession()
                case .splash:
                    break
                }
            }
        }
    }

    // Guards against a duplicate `.authenticated` emission rebuilding the whole session,
    // which would discard the in-memory workout and loaded state mid-session.
    private func setupAuthenticatedSession() async {
        // swiftlint:disable:next conditional_returns_on_newline
        guard appState != .authenticated else { return }
        // swiftlint:disable:next conditional_returns_on_newline
        guard let firebaseUser = container.authService.firebaseLoggedUser else { return }
        let appUser = firebaseUser.toAppUser()
        do {
            let exists = try await container.firebaseService.userExists(withId: firebaseUser.uid)
            if !exists {
                try await container.firebaseService.saveUserToDb(appUser)
            }
        } catch {
            logger.error("User not saved: \(error)")
        }
        let authenticatedContainer: AuthenticatedContainer
        do {
            authenticatedContainer = try AuthenticatedContainer(
                firebaseService: container.firebaseService,
                networkMonitorService: container.networkMonitorService,
                authService: container.authService,
                userDefaultsService: container.userDefaultsService,
                user: appUser
            )
        } catch {
            logger.error("Failed to create authenticated session: \(error)")
            await tearDownAuthenticatedSession()
            return
        }
        self.authenticatedContainer = authenticatedContainer
        setTabCoordinator(TabViewFlowCoordinator(authenticatedContainer: authenticatedContainer, selectedTab: .workouts))
        appState = .authenticated
    }

    // Awaited rather than fire-and-forget so the local store is wiped before a following
    // `.authenticated` emission builds a new session that would restore the previous user's workout.
    private func tearDownAuthenticatedSession() async {
        await authenticatedContainer?.clearUserData()
        authenticatedContainer = nil
        setTabCoordinator(nil)
        appState = .nonauthenticated
        loginCoordinator.path = []
    }

    private func setTabCoordinator(_ coordinator: TabViewFlowCoordinator?) {
        tabCoordinator = coordinator
    }
}

extension AppCoordinator: AppDelegateProtocol {
    // swiftlint:disable:next discouraged_optional_collection
    func applicationDidFinishLaunching(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        container.firebaseService.configure()
        container.authService.registerForStateDidChange()
    }
}
