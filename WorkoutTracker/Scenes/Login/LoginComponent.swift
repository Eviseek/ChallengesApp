//
//  LoginComponent.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 18.03.2026.
//

import FuturedArchitecture
import SwiftUI

struct LoginComponent<Model: LoginComponentModelProtocol>: View {
    @State var model: Model

    var body: some View {
        @Bindable var model = model
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.horizontal, Metrics.large)
            .safeAreaInset(edge: .bottom) {
                GoogleSignInButton(isLoading: model.isLoading) {
                    Task {
                        await model.loginWithGoogle()
                    }
                }
                .padding(.horizontal, Metrics.large)
                .padding(.bottom, Metrics.extraSmall)
            }
            .defaultAlert(model: $model.alertModel)
    }

    private var content: some View {
        VStack(spacing: 0) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.Brand.electricGreen)
                .padding(.bottom, Metrics.small)
                .decorative()
            Text("Workout Tracker")
                .font(.Archivo.hero)
                .foregroundStyle(Color.Brand.label)
                .padding(.bottom, Metrics.medium)
                .accessibleHeader()
            Text("Track every rep. Own your progress.")
                .font(.app(.subheadline))
                .foregroundStyle(Color.Brand.labelSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

#if DEBUG
#Preview {
    LoginComponent(
        model: LoginComponentModelMock()
    )
}
#endif
