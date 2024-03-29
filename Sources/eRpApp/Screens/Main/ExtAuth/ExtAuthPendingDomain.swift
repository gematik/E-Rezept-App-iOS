//
//  Copyright (c) 2024 gematik GmbH
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

    private enum CancelID {
        case login
    }

    struct State: Equatable {
        @PresentationState var destination: Destinations.State?

        var extAuthState: ExtAuthState

        init(
            destination: Destinations.State? = nil,
            extAuthState: ExtAuthState = ExtAuthState()
        ) {
            self.destination = destination
            self.extAuthState = extAuthState
        }
    }

    enum ExtAuthState: Equatable {
        init() {
            self = .empty
        }

        case empty
        case pendingExtAuth(KKAppDirectory.Entry)
        case extAuthReceived(KKAppDirectory.Entry)
        case extAuthSuccessful(KKAppDirectory.Entry)
        case extAuthFailed

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
        case externalLogin(URL)
        case saveProfile(error: LocalStoreError)
        /// Hides the visisble part of the view, e.g. while finishing a login. The view itself will stay in the
        /// hierarchy, to handle additional requests.
        case hide
        case cancelAllPendingRequests

        case destination(PresentationAction<Destinations.Action>)
        case response(Response)

        enum Response: Equatable {
            case pendingExtAuthRequestsReceived([ExtAuthChallengeSession])
            case externalLoginReceived(Result<IDPToken, Error>)
        }
    }

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            case extAuthAlert(ErpAlertState<Action.Alert>)
        }

        enum Action: Equatable {
            case alert(Alert)

            enum Alert: Equatable {
                case externalLogin(URL)
                case cancelAllPendingRequests
            }
        }

        var body: some ReducerProtocol<State, Action> {
            EmptyReducer()
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
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func core(state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .registerListener:
            return .publisher(
                environment.extAuthRequestStorage.pendingExtAuthRequests
                    .map { .response(.pendingExtAuthRequestsReceived($0)) }
                    .receive(on: schedulers.main.animation())
                    .eraseToAnyPublisher
            )
        case let .response(.pendingExtAuthRequestsReceived(requests)):
            if requests.isEmpty {
                if case .pendingExtAuth = state.extAuthState {
                    state.extAuthState = .empty
                }
            } else if let request = requests.first {
                switch state.extAuthState {
                case .extAuthFailed,
                     .empty:
                    state.extAuthState = .pendingExtAuth(request.entry)
                default:
                    break
                }
            }
            return .none
        // [REQ:BSI-eRp-ePA:O.Source_1#8] Validate data by parsing url and only allowing predefined variables as String
        case let .externalLogin(url),
             let .destination(.presented(.alert(.externalLogin(url)))):
            let environment = environment

            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            // gID only includes state and code, fasttrack uses kk_app_redirect_uri
            let isGidFlow = components?.queryItemWithName("kk_app_redirect_uri") == nil

            if let entry = state.extAuthState.entry {
                state.extAuthState = .extAuthReceived(entry)
            }

            return .publisher(
                environment.idTokenValidator
                    .mapError(Error.profileValidation)
                    .flatMap { idTokenValidator -> AnyPublisher<IDPToken, Error> in
                        environment.idpSession
                            .extAuthVerifyAndExchange(
                                url,
                                idTokenValidator: idTokenValidator.validate(idToken:),
                                isGidFlow: isGidFlow
                            )
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
                    .catchToPublisher()
                    .map { .response(.externalLoginReceived($0)) }
                    .receive(on: environment.schedulers.main.animation())
                    .eraseToAnyPublisher
            )
            .cancellable(id: CancelID.login, cancelInFlight: true)
        case let .response(.externalLoginReceived(.success(idpToken))):
            guard case let .extAuthReceived(entry) = state.extAuthState else { return .none }
            let payload = try? idpToken.idTokenPayload()
            state.extAuthState = .extAuthSuccessful(entry)
            let overrideInsuranceTypeToPkv = idpToken.isPkvFastTrackFlowInitiated
            return
                .concatenate(
                    .run { _ in
                        try await schedulers.main.sleep(for: 1)
                    },
                    environment.saveProfileWith(
                        insuranceId: payload?.idNummer,
                        insurance: payload?.organizationName,
                        givenName: payload?.givenName,
                        familyName: payload?.familyName,
                        overrideInsuranceTypeToPkv: overrideInsuranceTypeToPkv
                    )
                    .animation()
                )
        case .saveProfile:
            state.extAuthState = .extAuthFailed
            state.destination = .extAuthAlert(Self.saveProfileAlert)
            return .none
        case let .response(.externalLoginReceived(.failure(.idpError(error, url)))):
            guard case let .extAuthReceived(entry) = state.extAuthState else { return .none }
            let alertState = Self.alertState(
                title: entry.name,
                message: error.localizedDescriptionWithErrorList,
                url: url
            )
            state.extAuthState = .extAuthFailed
            state.destination = .extAuthAlert(alertState)
            return .none
        case let .response(.externalLoginReceived(.failure(.profileValidation(error: error)))):
            guard case let .extAuthReceived(entry) = state.extAuthState else { return .none }
            let alertState = Self.alertState(title: entry.name, message: error.localizedDescriptionWithErrorList)
            state.extAuthState = .extAuthFailed
            state.destination = .extAuthAlert(alertState)
            return .none
        case .hide:
            state.extAuthState = .empty
            return .none
        case .cancelAllPendingRequests,
             .destination(.presented(.alert(.cancelAllPendingRequests))):
            environment.extAuthRequestStorage.reset()
            state.extAuthState = .empty
            return .cancel(id: CancelID.login)
        case .destination:
            return .none
        }
    }

    static func alertState(title: String, message _: String, url: URL) -> ErpAlertState<Destinations.Action.Alert> {
        ErpAlertState(
            title: { TextState(L10n.mainTxtPendingextauthFailed(title)) },
            actions: {
                ButtonState(action: .send(.externalLogin(url))) {
                    TextState(L10n.mainTxtPendingextauthRetry)
                }
                ButtonState(role: .cancel, action: .send(.cancelAllPendingRequests)) {
                    TextState(L10n.mainTxtPendingextauthCancel)
                }
            },
            message: { TextState(L10n.cdwTxtRcAlertMessageSaveProfile) }
        )
    }

    static func alertState(title: String, message: String) -> ErpAlertState<Destinations.Action.Alert> {
        ErpAlertState(
            title: { TextState(title) },
            actions: {
                ButtonState(role: .cancel, action: .send(.cancelAllPendingRequests)) {
                    TextState(L10n.mainTxtPendingextauthCancel)
                }
            },
            message: { TextState(message) }
        )
    }

    static var saveProfileAlert: ErpAlertState<Destinations.Action.Alert> = {
        ErpAlertState(
            title: { TextState(L10n.cdwTxtExtauthAlertTitleSaveProfile) },
            actions: {
                ButtonState(role: .cancel, action: .send(.cancelAllPendingRequests)) {
                    TextState(L10n.cdwBtnExtauthAlertSaveProfile)
                }
            },
            message: { TextState(L10n.cdwTxtExtauthAlertMessageSaveProfile) }
        )
    }()
}

extension ExtAuthPendingDomain.Environment {
    func saveProfileWith(
        insuranceId: String?,
        insurance: String?,
        givenName: String?,
        familyName: String?,
        overrideInsuranceTypeToPkv: Bool = false
    ) -> EffectTask<ExtAuthPendingDomain.Action> {
        .publisher(
            currentProfile
                .first()
                .flatMap { profile -> AnyPublisher<Bool, LocalStoreError> in
                    profileDataStore.update(profileId: profile.id) { profile in
                        profile.insuranceId = insuranceId
                        // This is needed to ensure proper pKV faking.
                        // It can be removed when the debug option to fake pKV is removed.
                        if profile.insuranceType == .unknown {
                            profile.insuranceType = .gKV
                        }
                        // This is also temporary code until replaced by a proper implementation
                        if overrideInsuranceTypeToPkv {
                            profile.insuranceType = .pKV
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
                .eraseToAnyPublisher
        )
    }
}

extension ExtAuthPendingDomain {
    enum Dummies {
        static let state = State()

        static let store = store(for: state)

        static func store(for state: State) -> Store {
            Store(initialState: state) {
                EmptyReducer()
            }
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
