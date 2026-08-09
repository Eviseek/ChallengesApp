//
//  SetFloatingTextField.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 08.04.2026.
//

import SwiftUI

struct SetFloatingTextField: View {
    @Binding var text: String

    let title: LocalizedStringKey
    var placeholder: String = ""
    let keyboardType: UIKeyboardType
    let focusedField: FocusState<WorkoutFieldFocus?>.Binding
    let focusValue: WorkoutFieldFocus
    var calculateWidth: Bool = true

    var body: some View {
        SetFieldContainer(title: title, calculateWidth: calculateWidth) {
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .focused(focusedField, equals: focusValue)
                .accessibilityLabel(title)
        }
        .onTapGesture {
            focusedField.wrappedValue = focusValue
        }
    }
}
