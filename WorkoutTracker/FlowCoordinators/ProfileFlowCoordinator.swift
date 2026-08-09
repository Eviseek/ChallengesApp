//
//  ProfileFlowCoordinator.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 05.03.2026.
//

import FuturedArchitecture
import SwiftUI

@Observable
final class ProfileFlowCoordinator: @MainActor NavigationStackCoordinator {

    // MARK: - Public Properties

    var path: [Destination] = []
    var modalCover: ModalCoverModel<Destination>?

    // MARK: - Private Properties

    private var authenticatedContainer: AuthenticatedContainer

    // MARK: - Init

    init(authenticatedContainer: AuthenticatedContainer) {
        self.authenticatedContainer = authenticatedContainer
    }

    // MARK: - Public Methods

    static func rootView(with instance: ProfileFlowCoordinator) -> some View {
        NavigationStackFlow(coordinator: instance) {
            ProfileComponent(
                model: ProfileComponentModel(
                    workoutsService: instance.authenticatedContainer.workoutsService,
                    currentUserService: instance.authenticatedContainer.currentUserService,
                    authService: instance.authenticatedContainer.authService
                ) { _ in }
            )
        }
    }

    @ViewBuilder
    func scene(for destination: Destination) -> some View {
        switch destination {
        case .destination:
            EmptyView()
        }
    }
}

extension ProfileFlowCoordinator {
    nonisolated enum Destination: CaseIdentifiable {
        case destination

        var id: String {
            switch self {
            case .destination:
                "destination"
            }
        }
    }
}
