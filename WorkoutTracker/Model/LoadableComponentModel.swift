//
//  LoadableComponentModel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 17.07.2026.
//

/// Shared loading/error surface for component models that drive a `StateView`.
/// Conformers provide the raw flags; `screenState` is derived once here so every
/// scene (and its mock) maps them the same way.
protocol LoadableComponentModel: AnyObject {
    var isLoading: Bool { get }
    var loadError: AppError? { get set }
    /// Whether the loaded content is empty. Defaults to `false` for scenes that always
    /// have content once loaded.
    var isContentEmpty: Bool { get }
}

extension LoadableComponentModel {
    var isContentEmpty: Bool { false }

    var screenState: StateViewState {
        StateViewState(isLoading: isLoading, error: loadError, isEmpty: isContentEmpty)
    }
}
