//
//  TabViewFlowCoordinator.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 06.03.2026.
//

import FuturedArchitecture
import SwiftUI

@Observable
final class TabViewFlowCoordinator: @MainActor TabCoordinator {

    enum AppTab {
        case workouts
        case challenges
        case profile
    }

    // MARK: - Public Properties

    var selectedTab: AppTab
    var modalCover: ModalCoverModel<Destination>?

    // MARK: - Private Properties

    private let authenticatedContainer: AuthenticatedContainer
    private let workoutListCoordinator: WorkoutListFlowCoordinator
    private let challengesCoordinator: ChallengesFlowCoordinator
    private let profileCoordinator: ProfileFlowCoordinator

    private var isBottomAccessoryEnabled: Bool {
        authenticatedContainer.dataCache.value.currentWorkout != nil
    }

    // MARK: - Init

    init(authenticatedContainer: AuthenticatedContainer, selectedTab: AppTab) {
        self.authenticatedContainer = authenticatedContainer
        self.selectedTab = selectedTab
        self.workoutListCoordinator = WorkoutListFlowCoordinator(authenticatedContainer: authenticatedContainer)
        self.challengesCoordinator = ChallengesFlowCoordinator(authenticatedContainer: authenticatedContainer)
        self.profileCoordinator = ProfileFlowCoordinator(authenticatedContainer: authenticatedContainer)
    }

    // MARK: - Public Methods

    @ViewBuilder
    static func rootView(with instance: TabViewFlowCoordinator) -> some View {
        TabContentFlow(coordinator: instance) {
            SwiftUI.Tab("Workouts", systemImage: "house.fill", value: AppTab.workouts) {
                WorkoutListFlowCoordinator.rootView(
                    with: instance.workoutListCoordinator)
            }

            SwiftUI.Tab("Challenges", systemImage: "trophy.fill", value: AppTab.challenges) {
                ChallengesFlowCoordinator.rootView(
                    with: instance.challengesCoordinator)
            }

            SwiftUI.Tab("Profile", systemImage: "person.fill", value: AppTab.profile) {
                ProfileFlowCoordinator.rootView(
                    with: instance.profileCoordinator)
            }
        }
        .tabViewBottomAccessory(enabled: instance.isBottomAccessoryEnabled) {
            BottomAccessoryView(currentWorkout: instance.authenticatedContainer.dataCache.value.currentWorkout) {
                instance.present(modal: .workoutDetail, type: .fullscreenCover)
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(Color.Brand.electricGreen)
    }

    func scene(for destination: Destination) -> some View {
        switch destination {
        case .workoutDetail:
            WorkoutDetailFlowCoordinator.rootView(
                with: .init(authenticatedContainer: authenticatedContainer) { [weak self] event in
                    switch event {
                    case .dismiss:
                        self?.dismissModal()
                    }
                }
            )
        }
    }
}

extension TabViewFlowCoordinator {
    nonisolated enum Destination: CaseIdentifiable {
        case workoutDetail

        var id: String {
            switch self {
            case .workoutDetail:
                "workoutDetail"
            }
        }
    }
}
