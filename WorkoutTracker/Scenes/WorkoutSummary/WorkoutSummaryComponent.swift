//
//  WorkoutSummaryComponent.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 12.03.2026.
//

import FuturedArchitecture
import SwiftUI

struct WorkoutSummaryComponent<Model: WorkoutSummaryComponentModelProtocol>: View {
    @State var model: Model

    @State private var isEditable: Bool = false
    @FocusState private var focusedField: WorkoutFieldFocus?

    private var workoutNameBinding: Binding<String> {
        Binding(
            get: { model.workout.name },
            set: { model.workout.name = $0 }
        )
    }

    var body: some View {
        @Bindable var model = model
        List {
            WorkoutHeader(
                workoutName: workoutNameBinding,
                workoutDate: model.workout.date.workoutDisplayFormat,
                focusedField: $focusedField,
                isEditable: isEditable,
                accessibilityDateLabel: model.workout.date.workoutAccessibilityFormat(includingYear: true)
            )
            .listRowSeparator(.hidden)
            .listRowBackground(Color.Brand.clear)

            if !isEditable {
                statsCard
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.Brand.clear)
                    .listRowInsets(EdgeInsets(top: Metrics.mini, leading: Metrics.medium, bottom: Metrics.mini, trailing: Metrics.medium))
            }

            if !model.groupedExerciseSets.isEmpty {
                exerciseItems
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.inset)
        .tint(Color.Brand.electricGreen)
        .animation(.appStateChange, value: isEditable)
        .toolbar {
            toolbarItems
        }
        .defaultAlert(model: $model.alertModel)
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent { // swiftlint:disable:this attributes
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                model.startRepeatedWorkout()
            } label: {
                Image(systemName: "repeat")
            }
            .tint(Color.Brand.label)
            .accessibilityLabel("Repeat workout")
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                if isEditable {
                    focusedField = nil
                    Task {
                        await Task.yield()
                        if await model.saveWorkout() {
                            isEditable = false
                        }
                    }
                } else {
                    isEditable = true
                }
            } label: {
                Image(systemName: isEditable ? "checkmark" : "pencil")
            }
            .tint(isEditable ? Color.Brand.electricGreen : Color.Brand.label)
            .accessibilityLabel(isEditable ? Text("Save changes") : Text("Edit workout"))
        }
    }

    private var statsCard: some View {
        HStack(spacing: 0) {
            statBlock(label: "Duration", value: model.workout.duration.asWorkoutDurationLabel())
            Divider().decorative()
            statBlock(label: "Exercises", value: "\(model.groupedExerciseSets.count)")
            Divider().decorative()
            statBlock(label: "Sets", value: "\(model.workout.exerciseSets.count)")
        }
        .frame(maxWidth: .infinity)
        .padding(Metrics.medium)
        .background(Color.Brand.cardBackground, in: RoundedRectangle(cornerRadius: Metrics.roundCornerRadius))
        .accessibleCombined(label: statsCardLabel)
    }

    private var statsCardLabel: String {
        LocalizedText.workoutSummaryStats(
            duration: model.workout.duration.asAccessibleDurationLabel(),
            exercises: model.groupedExerciseSets.count,
            sets: model.workout.exerciseSets.count
        )
    }

    private func statBlock(label: LocalizedStringKey, value: String) -> some View {
        VStack(spacing: Metrics.extraMini) {
            Text(label)
                .textCase(.uppercase)
                .font(.app(.caption2, .bold))
                .foregroundStyle(Color.Brand.labelSecondary)
                .tracking(0.5)
            Text(value)
                .font(.Archivo.stat)
                .foregroundStyle(Color.Brand.label)
        }
        .frame(maxWidth: .infinity)
    }

    private var exerciseItems: some View {
        ForEach(model.groupedExerciseSets, id: \.exercise.id) { group in
            ExerciseItemView(
                isEditable: isEditable,
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
                    model.addSet(for: group.exercise)
                },
                onDeleteSet: { index in
                    model.deleteSet(for: group.exercise, at: index)
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
}

#if DEBUG
#Preview {
    WorkoutSummaryComponent(
        model: WorkoutSummaryComponentModelMock()
    )
}
#endif
