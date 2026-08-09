//
//  LoginComponentModel.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 18.03.2026.
//

import FuturedArchitecture
import Observation

protocol LoginComponentModelProtocol: ComponentModel, Observable {
    var alertModel: AlertModel? { get set }
    var isLoading: Bool { get }

    func loginWithGoogle() async
}

@Observable
final class LoginComponentModel: LoginComponentModelProtocol {

    // MARK: - Public Properties

    let onEvent: (Event) -> Void
    var isLoading: Bool = false
    var alertModel: AlertModel?

    // MARK: - Private Properties

    private let loginResource: LoginResourceProtocol

    // MARK: - Init

    init(
        resource: LoginResourceProtocol,
        onEvent: @escaping (Event) -> Void
    ) {
        self.loginResource = resource
        self.onEvent = onEvent
    }

    // MARK: - Public Methods

    func loginWithGoogle() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await loginResource.logInWithGoogle()
        } catch {
            alertModel = AlertModel(error: error)
        }
    }
}

extension LoginComponentModel {
    enum Event {
        case destination
    }
}

#if DEBUG
@Observable
final class LoginComponentModelMock: LoginComponentModelProtocol {
    typealias Event = LoginComponentModel.Event

    var onEvent: (Event) -> Void = { _ in }
    var alertModel: AlertModel?
    var isLoading: Bool = false

    func loginWithGoogle() async { }
}
#endif
