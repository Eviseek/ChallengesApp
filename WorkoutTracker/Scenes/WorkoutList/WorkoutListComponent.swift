//
//  WorkoutListComponent.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 05.03.2026.
//

import FuturedArchitecture
import SwiftUI

struct WorkoutListComponent<Model: WorkoutListComponentModelProtocol>: View {
    @State var model: Model

    @State private var sortOrder: WorkoutSortOrder = .newestFirst

    var body: some View {
        @Bindable var model = model
        StateView(
            state: model.screenState,
            retryAction: { Task { await model.retry() } },
            emptyStateView: { emptyStateView },
            content: { workoutListView }
        )
        .safeAreaInset(edge: .bottom) {
            if model.showsStartWorkoutButton {
                newWorkoutButton
                    .padding(.horizontal, Metrics.medium)
                    .padding(.vertical, Metrics.extraSmall)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: Metrics.animationDuration), value: model.showsStartWorkoutButton)
        .task(id: model.isLoading) {
            await model.onAppear()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !model.workouts.isEmpty {
                    sortButton
                }
            }
        }
        .navigationTitle("Workout Log")
        .navigationBarTitleDisplayMode(.inline)
        .defaultAlert(model: $model.alertModel)
    }

    // MARK: - Private Views

    private var workoutListView: some View {
        List {
            ForEach(model.workouts.groupedByWeek(sortOrder: sortOrder)) { group in
                Section {
                    ForEach(group.workouts, id: \.id) { workout in
                        Button {
                            model.openWorkoutSummary(workout)
                        } label: {
                            workoutCard(workout)
                        }
                        .foregroundStyle(Color.Brand.label)
                        .listRowBackground(Color.Brand.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: Metrics.mini, leading: Metrics.medium, bottom: Metrics.mini, trailing: Metrics.medium))
                        .swipeActions {
                            Button(role: .destructive) {
                                Task { await model.deleteWorkout(workout) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    weekSectionHeader(
                        label: group.label,
                        count: group.workouts.count,
                        isCurrent: group.isCurrent
                    )
                }
            }
        }
        .listStyle(.inset)
    }

    private var emptyStateView: some View {
        VStack(spacing: Metrics.small) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 44)) // Intentional fixed size — decorative empty-state icon.
                .foregroundStyle(Color.Brand.labelSecondary)
                .decorative()
            Text("No workouts yet")
                .font(.app(.headline))
            Text("Tap the button below to log your first session.")
                .font(.app(.subheadline))
                .foregroundStyle(Color.Brand.labelSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, Metrics.extraHuge)
        .accessibleCombined("No workouts yet. Tap the button below to log your first session.")
    }

    private var newWorkoutButton: some View {
        Button {
            model.openWorkoutDetail()
        } label: {
            HStack(spacing: Metrics.small) {
                Image(systemName: "plus")
                    .font(.subheadline.weight(.bold))
                Text("Start Workout")
                    .font(.app(.subheadline, .semibold))
            }
            .foregroundStyle(Color.Brand.onElectricGreen)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Metrics.medium)
            .background(Color.Brand.electricGreen, in: Capsule())
        }
    }

    private var sortButton: some View {
        Button {
            sortOrder = sortOrder == .newestFirst ? .oldestFirst : .newestFirst
        } label: {
            Image(systemName: sortOrder == .oldestFirst ? "arrow.up" : "arrow.up.arrow.down")
        }
        .tint(Color.Brand.electricGreen)
        .accessibilityLabel(sortOrder == .oldestFirst ? Text("Sort newest first") : Text("Sort oldest first"))
    }

    private func weekSectionHeader(
        label: String,
        count: Int,
        isCurrent: Bool
    ) -> some View {
        HStack(spacing: Metrics.extraSmall) {
            Text(label)
                .font(.app(.caption, .bold))
                .foregroundStyle(isCurrent ? Color.Brand.electricGreen : Color.secondary)
                .textCase(.uppercase)
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.Brand.separator)
                .decorative()
            Text(LocalizedText.workouts(count))
                .font(.app(.caption2))
                .foregroundStyle(Color.Brand.labelSecondary)
        }
        .textCase(nil)
        .padding(.horizontal, Metrics.medium)
        .padding(.vertical, Metrics.extraMini)
        .accessibleCombined(label: LocalizedText.weekSummary(label: label, workoutCount: count))
        .accessibleHeader()
    }

    private func workoutCard(_ workout: Workout) -> some View {
        VStack(alignment: .leading, spacing: Metrics.extraSmall) {
            HStack(alignment: .firstTextBaseline, spacing: Metrics.extraSmall) {
                Text(workout.date.workoutEyebrowFormat)
                    .font(.app(.caption2, .semibold))
                    .foregroundStyle(Color.Brand.labelSecondary)
                    .tracking(0.5)
                    .textCase(.uppercase)
                Spacer(minLength: Metrics.extraSmall)
                if workout.duration > 0 {
                    HStack(spacing: Metrics.mini) {
                        Image(systemName: "clock")
                        Text(workout.duration.asWorkoutDurationLabel())
                    }
                    .font(.app(.caption))
                    .foregroundStyle(Color.Brand.labelSecondary)
                }
            }
            Divider()
            VStack(alignment: .leading, spacing: Metrics.mini) {
                Text(workout.summary.workoutName)
                    .font(.app(.subheadline, .bold))
                    .lineLimit(1)
                ForEach(workout.summary.exerciseSummaries, id: \.self) { summary in
                    Text(summary.formatted)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(Color.Brand.labelSecondary)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Metrics.medium)
        .background(Color.Brand.cardBackground, in: RoundedRectangle(cornerRadius: Metrics.cardCornerRadius))
        .accessibleCombined(label: workoutCardLabel(workout))
    }

    private func workoutCardLabel(_ workout: Workout) -> String {
        var parts = [workout.summary.workoutName, workout.date.workoutAccessibilityFormat()]
        if workout.duration > 0 {
            parts.append(workout.duration.asAccessibleDurationLabel())
        }
        return parts.joined(separator: ", ")
    }
}

#if DEBUG
#Preview {
    WorkoutListComponent(
        model: WorkoutListComponentModelMock()
    )
}
#endif
