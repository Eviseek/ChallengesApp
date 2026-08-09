//
//  GoogleError.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 18.03.2026.
//

import GoogleSignIn

enum GoogleError: Error {
    case canceled
    case generic(Error)
    case missingIDToken
    case signInFailed(GIDSignInError)
    case viewControllerNotFound

    var shouldIgnore: Bool {
        switch self {
        case .canceled:
            true
        default:
            false
        }
    }

    init(error: Error) {
        switch error {
        case let error as GIDSignInError where error.code.rawValue == GIDSignInError.canceled.rawValue:
            self = .canceled
        case let error as GIDSignInError:
            self = .signInFailed(error)
        case let error as GoogleError where error == .viewControllerNotFound:
            self = .viewControllerNotFound
        default:
            self = .generic(error)
        }
    }
}

extension GoogleError: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.generic(lhsError), .generic(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.missingIDToken, .missingIDToken):
            return true
        case let (.signInFailed(lhsError), .signInFailed(rhsError)):
            return lhsError == rhsError
        case (.viewControllerNotFound, .viewControllerNotFound):
            return true
        case (.canceled, .canceled):
            return true
        default:
            return false
        }
    }
}
