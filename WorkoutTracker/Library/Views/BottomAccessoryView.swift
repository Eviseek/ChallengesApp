//
//  BottomAccessoryView.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 15.05.2026.
//

import SwiftUI

struct BottomAccessoryView: View {

    var currentWorkout: Workout?
    var action: () -> Void

    @State private var isPulsing = false

    private var statusText: String {
        (currentWorkout?.state ?? .running).statusText
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Metrics.small) {
                pulseDot
                    .decorative()
                workoutDetail
                duration
            }
            .padding(.horizontal, Metrics.preferredPadding)
            .padding(.vertical, Metrics.medium)
            .background(.ultraThinMaterial, in: Capsule())
        }
        // iOS 26.0 bug: default button style overrides the button's width, preventing it from filling the accessory area. .plain removes that constraint.
        .buttonStyle(.plain)
        .accessibilityLabel(
            currentWorkout?.accessibilityLabel
            ?? LocalizedText.nameAndStatus(name: String(localized: "Workout"), status: String(localized: "In progress"))
        )
        .onAppear {
            isPulsing = currentWorkout?.state == .paused
        }
        .onChange(of: currentWorkout?.state) { _, newState in
            isPulsing = newState == .paused
        }
    }

    private var workoutDetail: some View {
        VStack(alignment: .leading, spacing: Metrics.extraMini) {
            Text(currentWorkout?.name ?? String(localized: "Workout"))
                .font(.app(.subheadline, .semibold))
                .foregroundStyle(Color.Brand.label)
            Text(statusText)
                .font(.app(.caption))
                .foregroundStyle(Color.Brand.labelSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder private var duration: some View {
        if let duration = currentWorkout?.duration {
            Text(duration.asTimeString())
                .font(.app(.subheadline, .semibold))
                .foregroundStyle(Color.Brand.label)
        }
    }

    private var pulseDot: some View {
        Circle()
            .fill(Color.Brand.electricGreen)
            .frame(width: Metrics.extraSmall, height: Metrics.extraSmall)
            .opacity(isPulsing ? 0.3 : 1.0)
            .animation(
                isPulsing
                    ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                    : .default,
                value: isPulsing
            )
    }
}
