//
//  WorkoutExerciseItem.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 06.03.2026.
//

import SwiftUI

struct ExerciseItemView: View {

    var isEditable: Bool = true
    var groupedExerciseSets: (exercise: Exercise, sets: [ExerciseSet])
    var onRepsSetChanged: (_ setIndex: Int, _ reps: Int?, _ weight: Double?) -> Void
    var onDurationSetChanged: (_ setIndex: Int, _ duration: Int?) -> Void
    var onNoteChanged: (_ setIndex: Int, _ notes: String?) -> Void
    var onAddSet: () -> Void
    var onDeleteSet: (_ setIndex: Int) -> Void
    var onRemoveExercise: () -> Void
    let focusedField: FocusState<WorkoutFieldFocus?>.Binding

    var body: some View {
        VStack(spacing: 0) {
            cardHeader
            Divider()
            setsList
            if isEditable {
                addSetButton
            }
        }
        .padding(.bottom, isEditable ? 0 : Metrics.small)
        .background(Color.Brand.cardBackground, in: RoundedRectangle(cornerRadius: Metrics.cardCornerRadius))
    }

    // MARK: - Private Views

    private var cardHeader: some View {
        HStack(spacing: Metrics.mediumSmall) {
            Text(groupedExerciseSets.exercise.localizedName)
                .font(.app(.subheadline, .bold))
                .foregroundStyle(Color.Brand.label)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibleHeader()
            Text(groupedExerciseSets.exercise.muscleGroup.displayName)
                .font(.app(.caption2, .bold))
                .foregroundStyle(Color.Brand.labelSecondary)
                .textCase(.uppercase)
                .padding(.horizontal, Metrics.extraSmall)
                .padding(.vertical, Metrics.extraMini)
                .overlay(
                    RoundedRectangle(cornerRadius: Metrics.sharpCornerRadius)
                        .stroke(Color.Brand.separator, lineWidth: Metrics.normalBorderWidth)
                )
            if isEditable {
                Button {
                    onRemoveExercise()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(Color.Brand.labelSecondary)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Remove \(groupedExerciseSets.exercise.localizedName)")
            }
        }
        .padding(Metrics.medium)
    }

    private var setsList: some View {
        VStack(spacing: Metrics.mini) {
            ForEach(Array(groupedExerciseSets.sets.enumerated()), id: \.element.id) { index, exerciseSet in
                setRow(with: index, for: exerciseSet)
                    .contextMenu {
                        if isEditable {
                            Button(role: .destructive) {
                                onDeleteSet(index)
                            } label: {
                                Label("Delete Set", systemImage: "trash")
                            }
                        }
                    }
            }
        }
        .padding([.top, .horizontal], Metrics.small)
    }

    @ViewBuilder
    private func setRow(with index: Int, for set: ExerciseSet) -> some View {
        if groupedExerciseSets.exercise.type == .duration {
            DurationSetView(
                setNumber: index + 1,
                exerciseSet: set,
                focusedField: focusedField,
                onDurationChanged: { duration in
                    onDurationSetChanged(index, duration)
                },
                onNoteChanged: { notes in
                    onNoteChanged(index, notes)
                },
                onDelete: {
                    onDeleteSet(index)
                },
                isEditable: isEditable
            )
        } else {
            RepsSetView(
                setNumber: index + 1,
                exerciseSet: set,
                focusedField: focusedField,
                onChanged: { reps, weight in
                    onRepsSetChanged(index, reps, weight)
                },
                onNoteChanged: { notes in
                    onNoteChanged(index, notes)
                },
                onDelete: {
                    onDeleteSet(index)
                },
                isEditable: isEditable
            )
        }
    }

    private var addSetButton: some View {
        Button {
            onAddSet()
        } label: {
            HStack(alignment: .center, spacing: Metrics.extraSmall) {
                Image(systemName: "plus.circle.fill")
                    .imageScale(.medium)
                    .decorative()
                Text("Add set")
                    .font(.app(.subheadline, .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(Color.Brand.electricGreen)
            .contentShape(.rect)
            .padding(.horizontal, Metrics.small)
            .padding(.vertical, Metrics.medium)
        }
        .buttonStyle(.plain)
    }
}
