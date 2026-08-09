//
//  AppError.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 11.03.2026.
//

import Foundation

enum AppError: Error {
    case fetchFailed
    case saveFailed
    case general
    case loginFailed
    case deleteFailed
    case syncFailed
    case offline

    var title: String {
        switch self {
        case .fetchFailed:
            String(localized: "Couldn't load data.")
        case .saveFailed:
            String(localized: "Couldn't save data.")
        case .general:
            String(localized: "An unexpected error occurred.")
        case .loginFailed:
            String(localized: "Login has failed.")
        case .deleteFailed:
            String(localized: "Couldn't delete data.")
        case .syncFailed:
            String(localized: "Couldn't sync data.")
        case .offline:
            String(localized: "You are offline.")
        }
    }

    var message: String {
        switch self {
        case .fetchFailed, .saveFailed, .general, .loginFailed, .deleteFailed, .syncFailed:
            String(localized: "Please try again later.")
        case .offline:
            String(localized: "Check your connection and try again.")
        }
    }
}
