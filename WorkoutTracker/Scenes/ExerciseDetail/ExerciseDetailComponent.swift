//
//  ExerciseDetailComponent.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 06.03.2026.
//

import SwiftUI

struct ExerciseDetailComponent<Model: ExerciseDetailComponentModelProtocol>: View {
    @State var model: Model

    var body: some View {
        ScrollView(.vertical) {
            content
                .padding(.horizontal, Metrics.medium)
                .padding(.top, Metrics.medium)
        }
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                addButton
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Private Views

    private var content: some View {
        VStack(alignment: .leading, spacing: Metrics.medium) {
            Text(model.exercise.localizedName)
                .font(.app(.title2, .bold))
                .foregroundStyle(Color.Brand.label)
                .fixedSize(horizontal: false, vertical: true)
                .accessibleHeader()
            section(String(localized: "Muscle group"), value: model.exercise.muscleGroup.displayName)
            section(String(localized: "Type"), value: model.exercise.type.displayName)
            if let description = model.exercise.localizedDescription {
                section(String(localized: "Description"), value: description)
            }
        }
    }

    private func section(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Metrics.mini) {
            Text(label)
                .font(.app(.caption, .bold))
                .foregroundStyle(Color.Brand.electricGreen)
                .textCase(.uppercase)
            Text(value)
                .font(.app(.subheadline))
                .foregroundStyle(Color.Brand.label)
                .padding(Metrics.small)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.Brand.cardBackground, in: RoundedRectangle(cornerRadius: Metrics.roundCornerRadius))
        }
        .accessibleCombined(label: LocalizedText.labelAndValue(label: label, value: value))
    }

    private var addButton: some View {
        Button {
            model.onExerciseSelected()
        } label: {
            Text("Add")
                .font(.app(.subheadline, .semibold))
        }
        .tint(Color.Brand.electricGreen)
        .accessibilityLabel("Add exercise")
    }
}

#if DEBUG
#Preview {
    ExerciseDetailComponent(
        model: ExerciseDetailComponentModelMock()
    )
}
#endif
