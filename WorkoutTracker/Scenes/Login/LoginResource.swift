//
//  LoginResource.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 18.03.2026.
//

import Foundation

protocol LoginResourceProtocol {
    func logInWithGoogle() async throws(AppError)
}

struct LoginResource: LoginResourceProtocol {
    let authService: AuthService

    func logInWithGoogle() async throws(AppError) {
        try await authService.logInWithGoogle()
    }
}
