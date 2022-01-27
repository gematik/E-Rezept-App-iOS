//
//  Copyright (c) 2022 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//

import ComposableArchitecture
import IDP

enum ExtAuthPendingDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case pendingExtAuthRequestsSubscription
        case login
    }

    enum State: Equatable {
        init() {
            self = .empty
        }

        case empty
        case pendingExtAuth(KKAppDirectory.Entry)
        case extAuthReceived(KKAppDirectory.Entry)
        case extAuthSuccessful(KKAppDirectory.Entry)
        case extAuthFailed(AlertState<Action>)

        var entry: KKAppDirectory.Entry? {
            switch self {
            case let .pendingExtAuth(entry),
                 let .extAuthReceived(entry),
                 let .extAuthSuccessful(entry):
                return entry
            case .empty, .extAuthFailed:
                return nil
            }
        }
    }

    enum Error: Swift.Error, Equatable {
        case idpError(IDPError, URL)
    }

    enum Action: Equatable {
        case registerListener
        case unregisterListener
        case pendingExtAuthRequestsReceived([ExtAuthChallengeSession])
        case externalLogin(URL)
        case externalLoginReceived(Result<Bool, Error>)
        /// Hides the visisble part of the view, e.g. while finishing a login. The view itself will stay in the
        /// hierarchy, to handle additional requests.
        case hide
        case cancelAllPendingRequests
        case nothing
    }

    struct Environment {
        let idpSession: IDPSession
        let schedulers: Schedulers

        let extAuthRequestStorage: ExtAuthRequestStorage
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .registerListener:
            return environment.extAuthRequestStorage.pendingExtAuthRequests
                .map(Action.pendingExtAuthRequestsReceived)
                .receive(on: environment.schedulers.main.animation())
                .eraseToEffect()
                .cancellable(id: Token.pendingExtAuthRequestsSubscription, cancelInFlight: true)
        case .unregisterListener:
            return Effect.cancel(id: Token.pendingExtAuthRequestsSubscription)
        case let .pendingExtAuthRequestsReceived(requests):
            if requests.isEmpty {
                if case .pendingExtAuth = state {
                    state = .empty
                }
            } else if let request = requests.first {
                switch state {
                case .extAuthFailed,
                     .empty:
                    state = .pendingExtAuth(request.entry)
                default:
                    break
                }
            }
            return .none
        case let .externalLogin(url):
            let entry: KKAppDirectory.Entry?

            // If we have multipe pending requests, use the correct one
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
               let state = components.queryItemWithName("state")?.value,
               let newEntry = environment.extAuthRequestStorage.getExtAuthRequest(for: state)?.entry {
                entry = newEntry
            } else {
                // this should never happen, but do not throw the error here, let IDPSession decide
                entry = state.entry
            }

            guard let entry = entry else { return .none }

            state = .extAuthReceived(entry)
            return environment.idpSession
                .extAuthVerifyAndExchange(url)
                .map { _ in true }
                .mapError { .idpError($0, url) }
                .catchToEffect()
                .cancellable(id: Token.login, cancelInFlight: true)
                .map(Action.externalLoginReceived)
                .receive(on: environment.schedulers.main.animation())
                .eraseToEffect()
        case .externalLoginReceived(.success):
            guard case let State.extAuthReceived(entry) = state else { return .none }
            state = .extAuthSuccessful(entry)
            return Effect(value: Action.hide)
                .delay(for: 2,
                       scheduler: environment.schedulers.main.animation())
                .eraseToEffect()
        case let .externalLoginReceived(.failure(.idpError(error, url))):
            guard case let State.extAuthReceived(entry) = state else { return .none }
            let alertState = alertState(title: entry.name, message: error.localizedDescription, url: url)
            state = .extAuthFailed(alertState)
            return .none
        case .hide:
            state = .empty
            return .none
        case .cancelAllPendingRequests:
            environment.extAuthRequestStorage.reset()
            state = .empty
            return Effect.cancel(id: Token.login)
        case .nothing:
            return .none
        }
    }

    static func alertState(title: String, message: String, url: URL) -> AlertState<Action> {
        AlertState<Action>(
            title: TextState(L10n.mainTxtPendingextauthFailed(title)),
            message: TextState(message),
            primaryButton: .default(TextState(L10n.mainTxtPendingextauthRetry), send: .externalLogin(url)),
            secondaryButton: .cancel(TextState(L10n.mainTxtPendingextauthCancel), send: .cancelAllPendingRequests)
        )
    }

    static let reducer: Reducer = .combine(
        domainReducer
    )
}

extension ExtAuthPendingDomain {
    enum Dummies {
        static let state = State()
        static let environment = Environment(idpSession: DemoIDPSession(storage: MemoryStorage()),
                                             schedulers: Schedulers(),
                                             extAuthRequestStorage: DummyExtAuthRequestStorage())

        static let store = Store(initialState: state,
                                 reducer: .empty,
                                 environment: environment)

        static func store(for state: State) -> Store {
            Store(initialState: state,
                  reducer: .empty,
                  environment: environment)
        }
    }
}

extension ExtAuthPendingDomain.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .idpError(idpError, _):
            return idpError.localizedDescription
        }
    }
}

extension URLComponents {
    func queryItemWithName(_ name: String) -> URLQueryItem? {
        queryItems?.first { $0.name == name }
    }
}
