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

import Combine
import ComposableArchitecture
import eRpKit
import FHIRClient
import Foundation
import HTTPClient
import IDP

enum GroupedPrescriptionListDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    /// Provides an Effect that need to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(token: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case loadLocalPrescriptionId
        case fetchPrescriptionId
        case refreshId
    }

    struct Environment {
        let router: Routing
        let userSession: UserSession
        let serviceLocator: ServiceLocator
        let accessibilityAnnouncementReceiver: (String) -> Void
        let groupedPrescriptionStore: GroupedPrescriptionRepository
        let schedulers: Schedulers
        var fhirDateFormatter: FHIRDateFormatter
        /// To make sure enough time is left to redeem prescriptions we define a minimum
        /// number of minutes that need to be left before the session expires.
        let minLoginTimeLeftInMinutes: Int = 29

        var locale: String? {
            Locale.current.languageCode
        }

        let loginHandler: LoginHandler
        let signatureProvider: SecureEnclaveSignatureProvider
        let userSessionProvider: UserSessionProvider
    }

    struct State: Equatable {
        var loadingState: LoadingState<[GroupedPrescription], ErxRepositoryError> =
            .idle
        var groupedPrescriptions: [GroupedPrescription] = []

        var hintState = MainViewHintsDomain.State()
    }

    enum Action: Equatable {
        /// Loads locally stored GroupedPrescriptions
        case loadLocalGroupedPrescriptions
        /// Response from `loadLocalGroupedPrescriptions`
        case loadLocalGroupedPrescriptionsReceived(LoadingState<[GroupedPrescription], ErxRepositoryError>)
        ///  Loads GroupedPrescriptions from server and stores them in the local store
        case loadRemoteGroupedPrescriptionsAndSave
        /// Response from `loadRemoteGroupedPrescriptionsAndSave`
        // swiftlint:disable:next identifier_name
        case loadRemoteGroupedPrescriptionsAndSaveReceived(LoadingState<[GroupedPrescription], ErxRepositoryError>)
        /// Presents the CardWall when not logged in or executes `loadFromCloudAndSave`
        case refresh
        /// Dismisses the alert that showing loading errors
        case alertDismissButtonTapped
        /// Response from `refresh` that presents the CardWall sheet
        case showCardWallReceived(CardWallIntroductionDomain.State)

        /// Details actions
        case prescriptionDetailViewTapped(selectedPrescription: GroupedPrescription.Prescription)

        /// Redeem actions
        case redeemViewTapped(selectedGroupedPrescription: GroupedPrescription)

        /// Actions related to hint
        case hint(action: MainViewHintsDomain.Action)

        case errorReceived(LoginHandlerError)
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .loadLocalGroupedPrescriptions:
            state.loadingState = .loading(state.groupedPrescriptions)
            return environment.groupedPrescriptionStore.loadLocal()
                .receive(on: environment.schedulers.main.animation())
                .catchToLoadingStateEffect()
                .map(Action.loadLocalGroupedPrescriptionsReceived)
                .cancellable(id: Token.loadLocalPrescriptionId, cancelInFlight: true)
        case let .loadLocalGroupedPrescriptionsReceived(loadingState):
            state.loadingState = loadingState
            state.groupedPrescriptions = loadingState.value ?? []
            return .none
        case .loadRemoteGroupedPrescriptionsAndSave:
            state.loadingState = .loading(nil)
            return environment.loadRemoteTasksAndSave()
                .map(Action.loadRemoteGroupedPrescriptionsAndSaveReceived)
                .cancellable(id: Token.fetchPrescriptionId, cancelInFlight: true)
        case let .loadRemoteGroupedPrescriptionsAndSaveReceived(loadingState):
            state.loadingState = loadingState
            // prevent overriding values previously loaded from .loadLocalPrescriptions
            if case let .value(groupedPrescriptions) = loadingState, !groupedPrescriptions.isEmpty {
                state.groupedPrescriptions = groupedPrescriptions
            }
            return .none
        case .refresh:
            state.loadingState = .loading(nil)
            return environment.refreshOrShowCardWall().cancellable(id: Token.refreshId, cancelInFlight: true)
        case .alertDismissButtonTapped:
            state.loadingState = .idle
            return .none
        case .hint:
            return .none
        case .showCardWallReceived,
             .prescriptionDetailViewTapped,
             .redeemViewTapped:
            return .none
        case .errorReceived:
            state.loadingState = .idle
            return .none // Handled in parent domain
        }
    }

    static let reducer: Reducer = .combine(
        hintsPullbackReducer,
        domainReducer
    )

    static let hintsPullbackReducer: Reducer =
        MainViewHintsDomain.reducer
            .pullback(
                state: \.hintState,
                action: /GroupedPrescriptionListDomain.Action.hint(action:)
            ) { globalEnvironment in
                MainViewHintsDomain.Environment(
                    router: globalEnvironment.router,
                    userSession: globalEnvironment.userSession,
                    schedulers: globalEnvironment.schedulers,
                    hintEventsStore: globalEnvironment.userSession.hintEventsStore,
                    hintProvider: MainViewHintsProvider()
                )
            }
}

extension GroupedPrescriptionListDomain.Environment {
    typealias Action = GroupedPrescriptionListDomain.Action

    func cardWall() -> AnyPublisher<CardWallIntroductionDomain.State, Never> {
        let hideCardWallIntro = userSession.localUserStore.hideCardWallIntro
        let canAvailable = userSession.secureUserStore.can

        return canAvailable
            .combineLatest(hideCardWallIntro)
            .first()
            .map { _, _ in
                CardWallIntroductionDomain.State(
                    isNFCReady: serviceLocator.deviceCapabilities.isNFCReady,
                    profileId: userSession.profileId
                )
            }
            .eraseToAnyPublisher()
    }

    func loadRemoteTasksAndSave()
        -> Effect<LoadingState<[GroupedPrescription], ErxRepositoryError>, Never> {
        userSession
            .isAuthenticated
            .mapError { ErxRepositoryError.local(.initialization(error: $0)) }
            .first()
            .flatMap { isAuthenticated
                -> AnyPublisher<[GroupedPrescription], ErxRepositoryError> in

                if isAuthenticated {
                    return
                        groupedPrescriptionStore
                            .loadRemoteAndSave(for: locale)
                            .first()
                            .eraseToAnyPublisher()
                } else {
                    // return so the loadingState can be updated
                    return Just([])
                        .setFailureType(to: ErxRepositoryError.self)
                        .eraseToAnyPublisher()
                }
            }
            .map(LoadingState<[GroupedPrescription], ErxRepositoryError>.value)
            .catch { _ in Effect(value: LoadingState.idle).eraseToEffect() }
            .receive(on: schedulers.main.animation())
            .eraseToEffect()
    }

    func refreshOrShowCardWall() -> Effect<GroupedPrescriptionListDomain.Action, Never> {
        loginHandler
            .isAuthenticatedOrAuthenticate()
            .first()
            .receive(on: schedulers.main.animation())
            .flatMap { isAuthenticated -> Effect<GroupedPrescriptionListDomain.Action, Never> in
                // [REQ:gemSpec_eRp_FdV:A_20167,A_20172] no token/not authorized, show authenticator module
                if Result.success(false) == isAuthenticated {
                    return cardWall()
                        .receive(on: schedulers.main)
                        .map(GroupedPrescriptionListDomain.Action.showCardWallReceived)
                        .eraseToEffect()
                }
                if case let Result.failure(error) = isAuthenticated {
                    return Just(GroupedPrescriptionListDomain.Action.errorReceived(error))
                        .eraseToEffect()
                } else {
                    return groupedPrescriptionStore.loadRemoteAndSave(for: locale)
                        .receive(on: schedulers.main)
                        .first()
                        .map { value in
                            GroupedPrescriptionListDomain.Action
                                .loadRemoteGroupedPrescriptionsAndSaveReceived(LoadingState.value(value))
                        }
                        .catchUnauthorizedToShowCardwall(in: self)
                        .catch { error in
                            Just(GroupedPrescriptionListDomain.Action
                                .loadRemoteGroupedPrescriptionsAndSaveReceived(LoadingState.error(error)))
                        }
                        .eraseToEffect()
                }
            }
            .eraseToEffect()
    }
}

extension Publisher where Output == GroupedPrescriptionListDomain.Action, Failure == ErxRepositoryError {
    /// Catches "forbidden"/403 server response to show card wall. The acutual invalidation of any token is communicated
    /// within IDPInterceptor.
    ///
    /// - Parameter environment: The environment of the Screen
    /// - Returns: A Publisher that catches 403 server responses and transforms them into `showCardWallReceived`
    /// actions.
    func catchUnauthorizedToShowCardwall(
        in environment: GroupedPrescriptionListDomain.Environment
    )
        -> AnyPublisher<GroupedPrescriptionListDomain.Action, ErxRepositoryError> {
        tryCatch { (error: ErxRepositoryError) -> AnyPublisher<
            GroupedPrescriptionListDomain.Action,
            ErxRepositoryError
        > in
        if case let ErxRepositoryError
            .remote(.fhirClientError(FHIRClient.Error.httpError(.httpError(urlError)))) = error,
            urlError.code.rawValue == HTTPStatusCode.forbidden.rawValue ||
            urlError.code.rawValue == HTTPStatusCode.unauthorized.rawValue {
            return environment.cardWall()
                .receive(on: environment.schedulers.main.animation())
                .map(GroupedPrescriptionListDomain.Action.showCardWallReceived)
                .setFailureType(to: ErxRepositoryError.self)
                .eraseToAnyPublisher()
        }
        throw error as ErxRepositoryError
        }
        .mapError { $0 as! ErxRepositoryError } // swiftlint:disable:this force_cast
        .eraseToAnyPublisher()
    }
}

extension GroupedPrescriptionListDomain {
    enum Dummies {
        static let demoSessionContainer = DummyUserSessionContainer()
        static let state = State()
        static let stateWithTwoPrescriptions = State(
            loadingState: .value([GroupedPrescription.Dummies.prescriptions]),
            groupedPrescriptions: [GroupedPrescription.Dummies.prescriptions],
            hintState: MainViewHintsDomain.Dummies.emptyState()
        )

        static let environment = Environment(
            router: DummyRouter(),
            userSession: demoSessionContainer.userSession,
            serviceLocator: ServiceLocator(),
            accessibilityAnnouncementReceiver: { _ in },
            groupedPrescriptionStore: GroupedPrescriptionInteractor(
                erxTaskInteractor: demoSessionContainer.userSession.erxTaskRepository
            ),
            schedulers: Schedulers(),
            fhirDateFormatter: FHIRDateFormatter.shared,
            loginHandler: DummyLoginHandler(),
            signatureProvider: DummySecureEnclaveSignatureProvider(),
            userSessionProvider: DummyUserSessionProvider()
        )
        static let store = Store(initialState: state,
                                 reducer: domainReducer,
                                 environment: environment)

        static func storeFor(_ state: State) -> Store {
            Store(
                initialState: state,
                reducer: domainReducer,
                environment: environment
            )
        }
    }
}
