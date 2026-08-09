//
//  RepsSetView.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 10.03.2026.
//

import SwiftUI

struct RepsSetView: View {

    var setNumber: Int
    var exerciseSet: ExerciseSet
    let focusedField: FocusState<WorkoutFieldFocus?>.Binding
    var onChanged: (_ reps: Int?, _ weight: Double?) -> Void
    var onNoteChanged: (_ notes: String?) -> Void
    var onDelete: (() -> Void)?
    var isEditable: Bool = true

    @State private var weightText: String
    @State private var repsText: String
    @State private var noteText: String

    init(
        setNumber: Int,
        exerciseSet: ExerciseSet,
        focusedField: FocusState<WorkoutFieldFocus?>.Binding,
        onChanged: @escaping (_ reps: Int?, _ weight: Double?) -> Void,
        onNoteChanged: @escaping (_ notes: String?) -> Void,
        onDelete: (() -> Void)? = nil,
        isEditable: Bool = true
    ) {
        self.isEditable = isEditable
        self.setNumber = setNumber
        self.exerciseSet = exerciseSet
        self.focusedField = focusedField
        self.onChanged = onChanged
        self.onNoteChanged = onNoteChanged
        self.onDelete = onDelete
        self._weightText = State(initialValue: exerciseSet.formattedWeight ?? "")
        self._repsText = State(initialValue: exerciseSet.reps.map { String($0) } ?? "")
        self._noteText = State(initialValue: exerciseSet.notes ?? "")
    }

    var isFilledOut: Bool {
        isEditable
            ? !weightText.isEmpty && !repsText.isEmpty
            : exerciseSet.weight != nil && exerciseSet.reps != nil
    }

    private var repsPlaceholder: String {
        exerciseSet.placeholder?.reps.map(String.init) ?? "0"
    }

    private var notePlaceholder: String {
        exerciseSet.placeholder?.notes ?? ""
    }

    var body: some View {
        SetRowView(setNumber: setNumber, isFilledOut: isFilledOut, onDelete: isEditable ? onDelete : nil) {
            if isEditable {
                editableView
            } else {
                nonEditableView
            }
        }
        .onChange(of: focusedField.wrappedValue) { oldValue, _ in
            let watchedFields: Set<WorkoutFieldFocus> = [
                .weight(setID: exerciseSet.id),
                .reps(setID: exerciseSet.id),
                .note(setID: exerciseSet.id)
            ]
            if let oldValue, watchedFields.contains(oldValue) {
                commitChanges()
            }
        }
        // Re-sync the local text state when the set changes underneath the view
        // (Firestore reload, repeat-workout prefill, edit-mode toggle).
        .onChange(of: exerciseSet) { _, newValue in
            weightText = newValue.weight.map { String($0.formatted(.compactDecimal)) } ?? ""
            repsText = newValue.reps.map { String($0) } ?? ""
            noteText = newValue.notes ?? ""
        }
    }

    @ViewBuilder private var editableView: some View {
        SetFloatingTextField(
            text: $weightText,
            title: "Weight",
            placeholder: exerciseSet.weightPlaceholder,
            keyboardType: .decimalPad,
            focusedField: focusedField,
            focusValue: .weight(setID: exerciseSet.id)
        )
        SetFloatingTextField(
            text: $repsText,
            title: "Reps",
            placeholder: repsPlaceholder,
            keyboardType: .numberPad,
            focusedField: focusedField,
            focusValue: .reps(setID: exerciseSet.id)
        )
        SetFloatingTextField(
            text: $noteText,
            title: "Note",
            placeholder: notePlaceholder,
            keyboardType: .default,
            focusedField: focusedField,
            focusValue: .note(setID: exerciseSet.id),
            calculateWidth: false
        )
    }

    @ViewBuilder private var nonEditableView: some View {
        SetDisplayField(
            title: "Weight",
            value: exerciseSet.formattedWeight
        )
        SetDisplayField(
            title: "Reps",
            value: exerciseSet.reps.map { String($0) }
        )
        SetDisplayField(
            title: "Note",
            value: exerciseSet.notes,
            calculateWidth: false
        )
    }

    private func commitChanges() {
        onChanged(Int(repsText), weightText.normalized)
        onNoteChanged(noteText.isEmpty ? nil : noteText)
    }
}

#if DEBUG
#Preview {
    @Previewable @FocusState var focus: WorkoutFieldFocus?
    RepsSetView(
        setNumber: 1,
        exerciseSet: ExerciseSet(exercise: .benchPress, reps: 8, weight: 80, duration: nil, notes: "Felt strong"),
        focusedField: $focus,
        onChanged: { _, _ in },
        onNoteChanged: { _ in }
    )
    .padding()
}
#endif
