//
//  ExerciseListComponent.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 06.03.2026.
//

import SwiftUI

struct ExerciseListComponent<Model: ExerciseListComponentModelProtocol>: View {
    @State var model: Model

    var body: some View {
        List {
            ForEach(model.filteredExercises, id: \.self) { exercise in
                HorizontalPickableItem(
                    text: exercise.localizedName,
                    subtitle: "\(String(localized: "Type")): \(exercise.type.displayName)",
                    mainAction: { model.onExerciseSelected(exercise) },
                    infoAction: { model.onInfoButtonClicked(for: exercise) }
                )
                .listRowBackground(Color.Brand.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: Metrics.mini, leading: Metrics.medium, bottom: Metrics.mini, trailing: Metrics.medium))
            }
        }
        .listStyle(.inset)
        .navigationTitle(model.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $model.searchText, prompt: "Search exercises")
    }
}

#if DEBUG
#Preview {
    ExerciseListComponent(
        model: ExerciseListComponentModelMock()
    )
}
#endif
