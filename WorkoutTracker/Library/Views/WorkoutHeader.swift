//
//  WorkoutHeader.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 15.04.2026.
//

import SwiftUI

struct WorkoutHeader: View {

    @Binding var workoutName: String
    let workoutDate: String?
    let accessibilityDateLabel: String?
    let focusedField: FocusState<WorkoutFieldFocus?>.Binding
    var isEditable: Bool = true

    init(
        workoutName: Binding<String>,
        workoutDate: String?,
        focusedField: FocusState<WorkoutFieldFocus?>.Binding,
        isEditable: Bool = true,
        accessibilityDateLabel: String? = nil
    ) {
        self._workoutName = workoutName
        self.workoutDate = workoutDate
        self.accessibilityDateLabel = accessibilityDateLabel
        self.focusedField = focusedField
        self.isEditable = isEditable
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.extraSmall) {
            textField
            if let workoutDate {
                workoutDateView(workoutDate)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Metrics.small)
    }

    private var isFocused: Bool {
        focusedField.wrappedValue == .workoutName
    }

    private var textField: some View {
        Group {
            if isEditable {
                HStack(spacing: Metrics.extraSmall) {
                    TextField("Name your workout", text: $workoutName)
                        .focused(focusedField, equals: .workoutName)
                    if !isFocused {
                        Image(systemName: "pencil")
                            .font(.app(.subheadline))
                            .foregroundStyle(Color.Brand.labelSecondary)
                            .decorative()
                    }
                }
                .contentShape(.rect)
                .onTapGesture { focusedField.wrappedValue = .workoutName }
                .overlay(alignment: .bottom) {
                    Divider()
                        .padding(.top, Metrics.extraMini)
                }
                .animation(.appToggle, value: isFocused)
            } else {
                Text(workoutName)
            }
        }
        .font(.app(.body, .bold))
        .lineLimit(1)
    }

    private func workoutDateView(_ date: String) -> some View {
        HStack(spacing: Metrics.mini) {
            Image(systemName: "calendar")
                .decorative()
            Text(date)
        }
        .font(.app(.caption, .semibold))
        .foregroundStyle(Color.Brand.labelSecondary)
        .padding(.horizontal, Metrics.extraSmall)
        .padding(.vertical, Metrics.extraMini)
        .overlay(
            RoundedRectangle(cornerRadius: Metrics.sharpCornerRadius)
                .stroke(Color.Brand.separator, lineWidth: Metrics.normalBorderWidth)
        )
        .accessibleCombined(label: accessibilityDateLabel ?? date)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var name = "Push Day"
    @Previewable @FocusState var focus: WorkoutFieldFocus?
    WorkoutHeader(
        workoutName: $name,
        workoutDate: Date().workoutDisplayFormat,
        focusedField: $focus
    )
    .padding()
}
#endif
