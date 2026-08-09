//
//  GoogleService.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 18.03.2026.
//

import FirebaseAuth
import GoogleSignIn

protocol GoogleService {
    func logIn(clientID: String) async throws(GoogleError) -> AuthDataResult
}

final class ProductionGoogleService: GoogleService {

    // MARK: - Public Methods

    func logIn(clientID: String) async throws(GoogleError) -> AuthDataResult {
        guard let rootViewController = UIApplication.shared.rootViewController else {
            throw GoogleError.viewControllerNotFound
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        do {
            // Start the sign in flow with email scope hint
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController,
                hint: nil,
                additionalScopes: ["email"]
            )
            let user = result.user

            guard let idToken = user.idToken?.tokenString else {
                throw GoogleError.missingIDToken
            }
            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )
            return try await Auth.auth().signIn(with: credential)
        } catch {
            throw GoogleError(error: error)
        }
    }
}
