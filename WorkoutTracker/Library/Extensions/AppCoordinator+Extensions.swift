//
//  AppCoordinator+Extensions.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 07.04.2026.
//

import SwiftUI

extension AppCoordinator {

    var splashView: some View {
        VStack(spacing: Metrics.extraHuge) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.Brand.electricGreen)
            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    @MainActor var authenticationView: some View {
        LoginFlowCoordinator.rootView(with: loginCoordinator)
    }

    @MainActor @ViewBuilder var appView: some View {
        if let tabCoordinator {
            TabViewFlowCoordinator.rootView(with: tabCoordinator)
        }
    }
}
