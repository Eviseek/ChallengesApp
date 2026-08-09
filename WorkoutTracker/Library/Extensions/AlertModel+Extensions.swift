//
//  AlertModel+Extensions.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 11.03.2026.
//

import Foundation
import FuturedArchitecture

extension AlertModel {
    init(error: AppError, primaryAction: ButtonAction? = nil) {
        self.init(title: error.title, message: error.message, primaryAction: primaryAction)
    }
}
