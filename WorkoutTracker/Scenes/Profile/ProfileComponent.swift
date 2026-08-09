//
//  ProfileComponent.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 18.03.2026.
//

import FuturedArchitecture
import SwiftUI

struct ProfileComponent<Model: ProfileComponentModelProtocol>: View {
    @State var model: Model

    var body: some View {
        @Bindable var model = model
        ScrollView {
            contentSection
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .tint(Color.Brand.electricGreen)
        .defaultAlert(model: $model.alertModel)
    }

    // MARK: - Content

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: Metrics.extraLarge) {
            statsSection
            accountSection
        }
        .padding(.horizontal, Metrics.medium)
        .padding(.top, Metrics.medium)
        .padding(.bottom, Metrics.extraHuge)
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: Metrics.small) {
            Text(String(localized: "Your stats"))
                .font(.caption.weight(.heavy))
                .fontDesign(.monospaced)
                .tracking(2)
                .foregroundStyle(Color.Brand.labelSecondary)
                .textCase(.uppercase)
                .accessibleHeader()
            statsGrid
        }
    }

    private var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: Metrics.small), GridItem(.flexible(), spacing: Metrics.small)],
            spacing: Metrics.small
        ) {
            AchievementTileView(
                icon: "dumbbell.fill",
                iconColor: Color.Brand.electricGreen,
                value: model.workoutCount.description,
                label: String(localized: "Workouts"),
                accessibilityLabel: LocalizedText.workouts(model.workoutCount)
            )
            AchievementTileView(
                icon: "clock.fill",
                iconColor: Color.Brand.electricGreen,
                value: model.timeTrainedValue,
                label: model.timeTrainedLabel,
                accessibilityLabel: model.timeTrainedAccessibilityLabel
            )
            AchievementTileView(
                icon: "figure.strengthtraining.traditional",
                iconColor: Color.Brand.electricGreen,
                value: model.uniqueExerciseCount.description,
                label: String(localized: "Exercises Tried"),
                accessibilityLabel: LocalizedText.exercisesTried(model.uniqueExerciseCount)
            )
            AchievementTileView(
                icon: "scalemass.fill",
                iconColor: Color.Brand.electricGreen,
                value: model.heaviestLift,
                label: String(localized: "Max Weight")
            )
        }
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: Metrics.small) {
            Text("Account")
                .textCase(.uppercase)
                .font(.caption.weight(.heavy))
                .fontDesign(.monospaced)
                .tracking(2)
                .foregroundStyle(Color.Brand.labelSecondary)
                .accessibleHeader()
            userInfoCard
            logoutButton
        }
    }

    private var userInfoCard: some View {
        HStack(spacing: Metrics.medium) {
            AsyncImage(url: model.currentUser.imageUrl) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                AvatarView(name: model.currentUser.displayName, size: 44, isCurrentUser: true)
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            .decorative()
            VStack(alignment: .leading, spacing: 2) {
                Text(model.currentUser.displayName)
                    .font(.app(.subheadline, .semibold))
                    .foregroundStyle(Color.Brand.label)
                Text(model.currentUser.email)
                    .font(.app(.footnote))
                    .foregroundStyle(Color.Brand.labelSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Metrics.medium)
        .background(Color.Brand.cardBackground, in: RoundedRectangle(cornerRadius: Metrics.roundCornerRadius))
    }

    private var logoutButton: some View {
        Button {
            model.logOut()
        } label: {
            HStack(spacing: Metrics.small) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.Brand.destructive.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18, weight: .bold))
                }
                .decorative()
                Text("Log out")
            }
            .font(.app(.subheadline, .semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Metrics.medium)
        }
        .buttonStyle(LogoutButtonStyle())
    }
}

private struct LogoutButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.Brand.destructive)
            .contentShape(.rect)
            .background(Color.Brand.cardBackground, in: RoundedRectangle(cornerRadius: Metrics.roundCornerRadius))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#if DEBUG
#Preview {
    ProfileComponent(
        model: ProfileComponentModelMock()
    )
}
#endif
