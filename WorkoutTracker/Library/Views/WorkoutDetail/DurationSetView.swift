//
//  DurationSetView.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 10.03.2026.
//

import SwiftUI

struct DurationSetView: View {

    var setNumber: Int
    var exerciseSet: ExerciseSet
    let focusedField: FocusState<WorkoutFieldFocus?>.Binding
    var onDurationChanged: (_ duration: Int?) -> Void
    var onNoteChanged: (_ notes: String?) -> Void
    var onDelete: (() -> Void)?
    var isEditable: Bool = true

    @State private var durationText: String
    @State private var noteText: String

    init(
        setNumber: Int,
        exerciseSet: ExerciseSet,
        focusedField: FocusState<WorkoutFieldFocus?>.Binding,
        onDurationChanged: @escaping (_ duration: Int?) -> Void,
        onNoteChanged: @escaping (_ notes: String?) -> Void,
        onDelete: (() -> Void)? = nil,
        isEditable: Bool = true
    ) {
        self.isEditable = isEditable
        self.setNumber = setNumber
        self.exerciseSet = exerciseSet
        self.focusedField = focusedField
        self.onDurationChanged = onDurationChanged
        self.onNoteChanged = onNoteChanged
        self.onDelete = onDelete
        self._durationText = State(initialValue: exerciseSet.formattedDuration ?? "")
        self._noteText = State(initialValue: exerciseSet.notes ?? "")
    }

    var isFilledOut: Bool {
        isEditable ? !durationText.isEmpty : exerciseSet.duration != nil
    }

    private var notePlaceholder: String {
        exerciseSet.placeholder?.notes ?? ""
    }

    var body: some View {
        SetRowView(setNumber: setNumber, isFilledOut: isFilledOut, onDelete: isEditable ? onDelete : nil) {
            if isEditable {
                SetFloatingTextField(
                    text: $durationText,
                    title: "Duration",
                    placeholder: exerciseSet.durationPlaceholder,
                    keyboardType: .numberPad,
                    focusedField: focusedField,
                    focusValue: .duration(setID: exerciseSet.id)
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
            } else {
                SetDisplayField(
                    title: "Duration",
                    value: exerciseSet.formattedDuration
                )
                SetDisplayField(
                    title: "Note",
                    value: exerciseSet.notes,
                    calculateWidth: false
                )
            }
        }
        .onChange(of: focusedField.wrappedValue) { oldValue, _ in
            let watchedFields: Set<WorkoutFieldFocus> = [
                .duration(setID: exerciseSet.id),
                .note(setID: exerciseSet.id)
            ]
            if let oldValue, watchedFields.contains(oldValue) {
                commitChanges()
            }
        }
        // Re-sync the local text state when the set changes underneath the view
        // (Firestore reload, repeat-workout prefill, edit-mode toggle).
        .onChange(of: exerciseSet) { _, newValue in
            durationText = newValue.duration.map { String($0) } ?? ""
            noteText = newValue.notes ?? ""
        }
    }

    private func commitChanges() {
        onDurationChanged(durationText.isEmpty ? nil : Int(durationText))
        onNoteChanged(noteText.isEmpty ? nil : noteText)
    }
}

#if DEBUG
#Preview {
    @Previewable @FocusState var focus: WorkoutFieldFocus?
    DurationSetView(
        setNumber: 1,
        exerciseSet: ExerciseSet(exercise: .plank, reps: nil, weight: nil, duration: 60, notes: "60 sec hold"),
        focusedField: $focus,
        onDurationChanged: { _ in },
        onNoteChanged: { _ in }
    )
    .padding()
}
#endif
