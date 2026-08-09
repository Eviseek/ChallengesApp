//
//  WorkoutDetailComponent.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 06.03.2026.
//

import ActivityKit
import Combine
import FuturedArchitecture
import SwiftUI

nonisolated enum WorkoutFieldFocus: Hashable {
    case workoutName
    case reps(setID: UUID)
    case weight(setID: UUID)
    case duration(setID: UUID)
    case note(setID: UUID)

    var setID: UUID? {
        switch self {
        case .workoutName:
            return nil
        case let .reps(id):
            return id
        case let .weight(id):
            return id
        case let .duration(id):
            return id
        case let .note(id):
            return id
        }
    }
}

struct WorkoutDetailComponent<Model: WorkoutDetailComponentModelProtocol>: View {
    @State var model: Model

    @FocusState private var focusedField: WorkoutFieldFocus?
    @State private var isTimerBlinking = false

    var body: some View {
        @Bindable var model = model
        List {
            WorkoutHeader(
                workoutName: workoutNameBinding,
                workoutDate: nil,
                focusedField: $focusedField
            )
            .listRowSeparator(.hidden)
            .listRowBackground(Color.Brand.clear)

            if !model.groupedExerciseSets.isEmpty {
                exerciseItems
            } else {
                emptyStateView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.inset)
        .tint(Color.Brand.electricGreen)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            toolbarItems
        }
        .safeAreaInset(edge: .bottom) {
            bottomActionBar
        }
        .defaultAlert(model: $model.alertModel)
        .tint(Color.Brand.label)
        .navigationBarBackButtonHidden(true)
        .task { await model.onAppear() }
        .onChange(of: focusedField) { _, newFocus in
            if let setID = newFocus?.setID {
                model.activeSetChanged(setID: setID)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent { // swiftlint:disable:this attributes
        ToolbarItem(placement: .topBarLeading) {
            Button {
                model.dismissWithNoSave()
            } label: {
                Image(systemName: "chevron.down")
            }
            .tint(Color.Brand.labelSecondary)
            .accessibilityLabel("Dismiss workout")
        }
        ToolbarItem(placement: .topBarLeading) {
            Button {
                model.deleteWorkout()
            } label: {
                Image(systemName: "trash")
            }
            .tint(Color.Brand.labelSecondary)
            .accessibilityLabel("Delete workout")
        }
        ToolbarItem(placement: .principal) {
            timerView
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                focusedField = nil
                Task {
                    // resigns textfield just so that all values are saved
                    await Task.yield()
                    await model.finishWorkout()
                }
            } label: {
                Image(systemName: "checkmark")
            }
            .tint(Color.Brand.electricGreen)
            .accessibilityLabel("Finish workout")
        }
    }

    private var workoutNameBinding: Binding<String> {
        Binding(
            get: { model.workoutName },
            set: { model.workoutName = $0 }
        )
    }

    private var bottomActionBar: some View {
        VStack(spacing: Metrics.mediumSmall) {
            if focusedField == nil {
                floatingPauseButton
                    .padding(.horizontal, Metrics.medium)
            }
            HStack(spacing: Metrics.medium) {
                floatingAddExerciseButton
                if focusedField != nil {
                    floatingDoneButton
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(duration: 0.25, bounce: 0.1), value: focusedField != nil)
            .padding(.horizontal, Metrics.medium)
            .padding(.bottom, Metrics.extraSmall)
        }
    }

    private var exerciseItems: some View {
        ForEach(model.groupedExerciseSets, id: \.exercise.id) { group in
            ExerciseItemView(
                groupedExerciseSets: group,
                onRepsSetChanged: { setIndex, reps, weight in
                    model.updateSet(for: group.exercise, at: setIndex, reps: reps, weight: weight)
                },
                onDurationSetChanged: { setIndex, duration in
                    model.updateSet(for: group.exercise, at: setIndex, duration: duration)
                },
                onNoteChanged: { setIndex, notes in
                    model.updateSet(for: group.exercise, at: setIndex, notes: notes)
                },
                onAddSet: {
                    focusNewSet(for: group.exercise)
                },
                onDeleteSet: {
                    model.deleteSet(for: group.exercise, at: $0)
                },
                onRemoveExercise: {
                    model.removeExercise(group.exercise)
                },
                focusedField: $focusedField
            )
            .listRowBackground(Color.Brand.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: Metrics.mini, leading: Metrics.medium, bottom: Metrics.mini, trailing: Metrics.medium))
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: Metrics.small) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 44)) // Intentional fixed size — decorative empty-state icon.
                .foregroundStyle(Color.Brand.labelSecondary)
                .decorative()
            Text("No exercises yet")
                .font(.app(.headline))
            Text("Add your first exercise to start building this workout.")
                .font(.app(.subheadline))
                .foregroundStyle(Color.Brand.labelSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Metrics.extraHuge)
        .padding(.horizontal, Metrics.extraHuge)
        .listRowBackground(Color.Brand.clear)
        .listRowSeparator(.hidden)
        .accessibleCombined("No exercises yet. Add your first exercise to start building this workout.")
    }

    private func focusNewSet(for exercise: Exercise) {
        let newSetID = model.addSet(for: exercise)
        Task {
            await Task.yield()
            focusedField = exercise.type == .duration
                ? .duration(setID: newSetID)
                : .weight(setID: newSetID)
        }
    }

    private var floatingAddExerciseButton: some View {
        CapsuleGlassButton(text: String(localized: "Add exercise"), foregroundColor: Color.Brand.label, imageName: "plus") {
            focusedField = nil
            Task {
                await Task.yield()
                model.addExerciseClicked()
            }
        }
    }

    private var floatingDoneButton: some View {
        CapsuleGlassButton(text: String(localized: "Done"), foregroundColor: Color.Brand.label, imageName: "keyboard.chevron.compact.down") {
            focusedField = nil
        }
    }

    private var floatingPauseButton: some View {
        Button {
            focusedField = nil
            Task {
                await Task.yield()
                model.pauseButtonClicked()
            }
        } label: {
            HStack(spacing: Metrics.extraSmall) {
                Image(systemName: model.isTimerRunning ? "pause" : "play")
                Text(model.isTimerRunning ? "Pause workout" : "Resume workout")
                    .font(.app(.body, .semibold))
            }
            .foregroundStyle(Color.Brand.electricGreen)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Metrics.medium)
            .glassEffect(.regular, in: Capsule())
            .overlay(Capsule().stroke(Color.Brand.electricGreen.opacity(0.35), lineWidth: Metrics.normalBorderWidth))
        }
    }

    private var timerView: some View {
        Text(model.duration.asTimeString())
            .monospacedDigit()
            .foregroundStyle(model.isTimerRunning ? Color.Brand.electricGreen : Color.Brand.labelSecondary)
            .opacity(isTimerBlinking ? 0.2 : 1.0)
            .onChange(of: model.isTimerRunning, initial: true) { _, running in
                withAnimation(running ? .default : .easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    isTimerBlinking = !running
                }
            }
            .accessibilityLabel("Workout duration")
            .accessibilityValue(model.duration.asTimeString())
            .accessibilityAddTraits(.updatesFrequently)
    }
}
