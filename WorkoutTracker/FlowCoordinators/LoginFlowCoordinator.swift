//
//  LoginFlowCoordinator.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 18.03.2026.
//

import FuturedArchitecture
import SwiftUI

@Observable
final class LoginFlowCoordinator: @MainActor NavigationStackCoordinator {

    // MARK: - Public Properties

    var path: [Destination] = []
    var modalCover: ModalCoverModel<Destination>?

    // MARK: - Private Properties

    private var container: Container

    // MARK: - Init

    init(container: Container) {
        self.container = container
    }

    // MARK: - Public Methods

    static func rootView(with instance: LoginFlowCoordinator) -> some View {
        LoginComponent(
            model: LoginComponentModel(
               // dataCache: instance.container.dataCache,
                resource: LoginResource(
                    authService: instance.container.authService
                )
            ) { _ in }
        )
    }

    @ViewBuilder
    func scene(for destination: Destination) -> some View {
        switch destination {
        case .destination:
            EmptyView()
        }
    }
}

extension LoginFlowCoordinator {
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
