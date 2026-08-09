//
//  CategoryListComponent.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 06.03.2026.
//

import SwiftUI

struct CategoryListComponent<Model: CategoryListComponentModelProtocol>: View {
    @State var model: Model

    var body: some View {
        List {
            switch model.searchState {
            case .idle:
                idleView
            case .results:
                resultsView
            case .empty:
                emptyView
            }
        }
        .listStyle(.inset)
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $model.searchText, prompt: "Search exercises")
    }

    // MARK: - Private Views

    @ViewBuilder private var idleView: some View {
        ForEach(model.muscleGroups, id: \.self) { group in
            HorizontalTappableItem(
                text: group.displayName,
                iconSystemName: group.sfSymbol
            ) {
                model.onGroupSelected(group)
            }
            .listRowBackground(Color.Brand.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: Metrics.mini, leading: Metrics.medium, bottom: Metrics.mini, trailing: Metrics.medium))
        }
    }

    @ViewBuilder private var resultsView: some View {
        ForEach(model.filteredExercises, id: \.self) { exercise in
            HorizontalTappableItem(
                text: exercise.localizedName,
                subtitle: exercise.type.displayName
            ) {
                model.onExerciseSelected(exercise)
            }
            .listRowBackground(Color.Brand.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: Metrics.mini, leading: Metrics.medium, bottom: Metrics.mini, trailing: Metrics.medium))
        }
    }

    private var emptyView: some View {
        Text("No results")
            .foregroundStyle(Color.Brand.labelSecondary)
            .accessibilityLabel("No exercises found")
    }
}

#if DEBUG
#Preview {
    CategoryListComponent(
        model: CategoryListComponentModelMock()
    )
}
#endif
