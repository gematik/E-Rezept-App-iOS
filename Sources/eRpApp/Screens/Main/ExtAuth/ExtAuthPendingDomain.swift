//
//  Copyright (c) 2023 gematik GmbH
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

import Combine
import ComposableArchitecture
import eRpKit
import Foundation
import IDP

struct ExtAuthPendingDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
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
        case extAuthFailed(ErpAlertState<Action>)

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

    // sourcery: CodedError = "014"
    /// `ExtAuthPendingDomain` error types
    enum Error: Swift.Error, Equatable {
        // sourcery: errorCode = "01"
        /// Underlying `IDPError` for the external authentication agains `URL`
        case idpError(IDPError, URL)
        // sourcery: errorCode = "02"
        /// Error when `Profile` validation with the given authentication fails.
        /// Error is produces within the `IDPError.unspecified` error before saving the IDPToken
        case profileValidation(error: IDTokenValidatorError)
    }

    enum Action: Equatable {
        case registerListener
        case unregisterListener
        case externalLogin(URL)
        case saveProfile(error: LocalStoreError)
        /// Hides the visisble part of the view, e.g. while finishing a login. The view itself will stay in the
        /// hierarchy, to handle additional requests.
        case hide
        case cancelAllPendingRequests
        case nothing

        case response(Response)

        enum Response: Equatable {
            case pendingExtAuthRequestsReceived([ExtAuthChallengeSession])
            case externalLoginReceived(Result<IDPToken, Error>)
        }
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.idpSession) var idpSession: IDPSession
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.profileDataStore) var profileDataStore: ProfileDataStore
    @Dependency(\.extAuthRequestStorage) var extAuthRequestStorage: ExtAuthRequestStorage

    private var environment: Environment {
        .init(
            idpSession: idpSession,
            schedulers: schedulers,
            profileDataStore: profileDataStore,
            extAuthRequestStorage: extAuthRequestStorage,
            currentProfile: userSession.profile(),
            idTokenValidator: userSession.idTokenValidator()
        )
    }

    struct Environment {
        let idpSession: IDPSession
        let schedulers: Schedulers
        let profileDataStore: ProfileDataStore
        let extAuthRequestStorage: ExtAuthRequestStorage
        let currentProfile: AnyPublisher<Profile, LocalStoreError>
        let idTokenValidator: AnyPublisher<IDTokenValidator, IDTokenValidatorError>
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func core(state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .registerListener:
            return environment.extAuthRequestStorage.pendingExtAuthRequests
                .map { .response(.pendingExtAuthRequestsReceived($0)) }
                .receive(on: schedulers.main.animation())
                .eraseToEffect()
                .cancellable(id: Token.pendingExtAuthRequestsSubscription, cancelInFlight: true)
        case .unregisterListener:
            return Effect.cancel(id: Token.pendingExtAuthRequestsSubscription)
        case let .response(.pendingExtAuthRequestsReceived(requests)):
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
            let environment = environment
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
            return environment.idTokenValidator
                .mapError(Error.profileValidation)
                .flatMap { idTokenValidator -> AnyPublisher<IDPToken, Error> in
                    environment.idpSession
                        .extAuthVerifyAndExchange(url, idTokenValidator: idTokenValidator.validate(idToken:))
                        .mapError { error in
                            if case let .unspecified(error) = error,
                               let validationError = error as? IDTokenValidatorError {
                                return .profileValidation(error: validationError)
                            } else {
                                return .idpError(error, url)
                            }
                        }
                        .eraseToAnyPublisher()
                }
                .catchToEffect()
                .cancellable(id: Token.login, cancelInFlight: true)
                .map { .response(.externalLoginReceived($0)) }
                .receive(on: environment.schedulers.main.animation())
                .eraseToEffect()
        case let .response(.externalLoginReceived(.success(idpToken))):
            guard case let .extAuthReceived(entry) = state else { return .none }
            let payload = try? idpToken.idTokenPayload()
            state = .extAuthSuccessful(entry)
            return environment.saveProfileWith(
                insuranceId: payload?.idNummer,
                insurance: payload?.organizationName,
                givenName: payload?.givenName,
                familyName: payload?.familyName
            )
            .delay(for: 2,
                   scheduler: schedulers.main.animation())
            .eraseToEffect()
        case .saveProfile(error: _):
            state = .extAuthFailed(Self.saveProfileAlert)
            return .none
        case let .response(.externalLoginReceived(.failure(.idpError(error, url)))):
            guard case let .extAuthReceived(entry) = state else { return .none }
            let alertState = Self.alertState(
                title: entry.name,
                message: error.localizedDescriptionWithErrorList,
                url: url
            )
            state = .extAuthFailed(alertState)
            return .none
        case let .response(.externalLoginReceived(.failure(.profileValidation(error: error)))):
            guard case let .extAuthReceived(entry) = state else { return .none }
            let alertState = Self.alertState(title: entry.name, message: error.localizedDescriptionWithErrorList)
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

    static func alertState(title: String, message: String, url: URL) -> ErpAlertState<Action> {
        ErpAlertState(.init(
            title: TextState(L10n.mainTxtPendingextauthFailed(title)),
            message: TextState(message),
            primaryButton: .default(TextState(L10n.mainTxtPendingextauthRetry),
                                    action: .send(.externalLogin(url))),
            secondaryButton: .cancel(TextState(L10n.mainTxtPendingextauthCancel),
                                     action: .send(.cancelAllPendingRequests))
        ))
    }

    static func alertState(title: String, message: String) -> ErpAlertState<Action> {
        ErpAlertState(.init(
            title: TextState(title),
            message: TextState(message),
            dismissButton: .cancel(TextState(L10n.mainTxtPendingextauthCancel),
                                   action: .send(.cancelAllPendingRequests))
        ))
    }

    static var saveProfileAlert: ErpAlertState<Action> = {
        ErpAlertState(.init(
            title: TextState(L10n.cdwTxtExtauthAlertTitleSaveProfile),
            message: TextState(L10n.cdwTxtExtauthAlertMessageSaveProfile),
            dismissButton: .cancel(TextState(L10n.cdwBtnExtauthAlertSaveProfile),
                                   action: .send(.cancelAllPendingRequests))
        ))
    }()
}

extension ExtAuthPendingDomain.Environment {
    func saveProfileWith(
        insuranceId: String?,
        insurance: String?,
        givenName: String?,
        familyName: String?
    ) -> Effect<ExtAuthPendingDomain.Action, Never> {
        currentProfile
            .first()
            .flatMap { profile -> AnyPublisher<Bool, LocalStoreError> in
                profileDataStore.update(profileId: profile.id) { profile in
                    profile.insuranceId = insuranceId
                    // This is needed to ensure proper pKV faking and can be removed when the debug option to fake pKV
                    // is removed.
                    if profile.insuranceType == .unknown {
                        profile.insuranceType = .gKV
                    }
                    profile.insurance = insurance
                    profile.givenName = givenName
                    profile.familyName = familyName
                }
                .eraseToAnyPublisher()
            }
            .map { _ in
                ExtAuthPendingDomain.Action.hide
            }
            .catch { error in
                Just(ExtAuthPendingDomain.Action.saveProfile(error: error))
            }
            .receive(on: schedulers.main)
            .eraseToEffect()
    }
}

extension ExtAuthPendingDomain {
    enum Dummies {
        static let state = State()
        static let environment = Environment(
            idpSession: DemoIDPSession(storage: MemoryStorage()),
            schedulers: Schedulers(),
            profileDataStore: DemoProfileDataStore(),
            extAuthRequestStorage: DummyExtAuthRequestStorage(),
            currentProfile: DummySessionContainer().profile(),
            idTokenValidator: DummySessionContainer().idTokenValidator()
        )

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
        case let .profileValidation(error: error):
            return error.localizedDescription
        }
    }
}

extension URLComponents {
    func queryItemWithName(_ name: String) -> URLQueryItem? {
        queryItems?.first { $0.name == name }
    }
}
