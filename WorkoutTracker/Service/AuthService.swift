//
//  AuthService.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 18.03.2026.
//

import FirebaseAuth
import FirebaseCore
import Foundation

protocol AuthService {
    var stateStream: AsyncStream<AppState> { get }
    var firebaseLoggedUser: FirebaseAuth.User? { get }

    func logInWithGoogle() async throws(AppError)
    func logOut() throws(AppError)
    func registerForStateDidChange()
}

final class ProductionAuthService: NSObject, AuthService {

    // MARK: - Public Properties

    let stateStream: AsyncStream<AppState>

    var firebaseLoggedUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    // MARK: - Private Properties

    private let googleService: GoogleService
    private var authHandler: AuthStateDidChangeListenerHandle?
    private let continuation: AsyncStream<AppState>.Continuation

    // MARK: - Init

    init(googleService: GoogleService) {
        let (stream, continuation) = AsyncStream.makeStream(of: AppState.self)
        self.stateStream = stream
        self.continuation = continuation
        self.googleService = googleService
        super.init()
        continuation.yield(.splash)
    }

    // MARK: - Public Methods

    func registerForStateDidChange() {
        authHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.continuation.yield(user != nil ? .authenticated : .nonauthenticated)
        }
    }

    func logInWithGoogle() async throws(AppError) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AppError.general
        }
        do {
            _ = try await googleService.logIn(clientID: clientID)
        } catch {
            if error.shouldIgnore { return }
            throw AppError.loginFailed
        }
    }

    func logOut() throws(AppError) {
        do {
            try Auth.auth().signOut()
        } catch {
            throw AppError.general
        }
    }
}
