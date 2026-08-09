//  
//  WorkoutTrackerApp.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 04.03.2026.
//

import SwiftUI

@main
struct WorkoutTrackerApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @State private var coordinator: AppCoordinator

    init() {
        let coordinator = AppCoordinator(container: Container())
        self._coordinator = State(wrappedValue: coordinator)
        self.appDelegate.delegate = coordinator
    }

    var body: some Scene {
        WindowGroup {
            content
                .environment(\.font, .appDefault)
                .animation(.default, value: coordinator.appState)
        }
    }

    @ViewBuilder private var content: some View {
        switch coordinator.appState {
        case .splash:
            coordinator.splashView
        case .nonauthenticated:
            coordinator.authenticationView
        case .authenticated:
            coordinator.appView
        }
    }
}
