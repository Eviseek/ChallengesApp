//
//  StateViewState.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 22.06.2026.
//

import Foundation

enum StateViewState: Equatable {
    case loading
    case error(AppError)
    case empty
    case content

    init(isLoading: Bool, error: AppError?, isEmpty: Bool) {
        if isLoading {
            self = .loading
        } else if let error {
            self = .error(error)
        } else if isEmpty {
            self = .empty
        } else {
            self = .content
        }
    }
}
