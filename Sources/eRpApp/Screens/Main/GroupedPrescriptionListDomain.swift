//
//  Copyright (c) 2021 gematik GmbH
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
    }

    struct State: Equatable {
        var loadingState: LoadingState<[GroupedPrescription], ErxTaskRepositoryError> =
            .idle

        // sub states
        var cardWallState: CardWallDomain.State?
        var groupedPrescriptions: [GroupedPrescription] = []

        // details state
        var selectedPrescriptionDetailState: PrescriptionDetailDomain.State?

        // redeem state
        var redeemState: RedeemDomain.State?
        var hintState = MainViewHintsDomain.State()
    }

    enum Action: Equatable {
        /// Loads locally stored GroupedPrescriptions
        case loadLocalGroupedPrescriptions
        /// Response from `loadLocalGroupedPrescriptions`
        case loadLocalGroupedPrescriptionsReceived(LoadingState<[GroupedPrescription], ErxTaskRepositoryError>)
        ///  Loads GroupedPrescriptions from server and stores them in the local store
        case loadRemoteGroupedPrescriptionsAndSave
        /// Response from `loadRemoteGroupedPrescriptionsAndSave`
        // swiftlint:disable:next identifier_name
        case loadRemoteGroupedPrescriptionsAndSaveReceived(LoadingState<[GroupedPrescription], ErxTaskRepositoryError>)
        /// Presents the CardWall when not logged in or executes `loadFromCloudAndSave`
        case refresh
        /// Dismisses the alert that showing loading errors
        case alertDismissButtonTapped
        /// Response from `refresh` that presents the CardWall sheet
        case showCardWallReceived(CardWallDomain.State)
        /// Hides the `CardWallView` sheet
        case dismissCardWall
        /// Removes all subscriptions
        case removeSubscriptions
        /// Child view actions of the `CardWallDomain`
        case cardWall(action: CardWallDomain.Action)

        /// Details actions
        case prescriptionDetailViewTapped(selectedPrescription: ErxTask)
        case dismissPrescriptionDetailView
        case prescriptionDetailAction(action: PrescriptionDetailDomain.Action)

        /// Redeem actions
        case redeemViewTapped(selectedGroupedPrescription: GroupedPrescription)
        /// Dismisses the redeem view
        case dismissRedeemView
        case redeemView(action: RedeemDomain.Action)

        /// Actions related to hint
        case hint(action: MainViewHintsDomain.Action)
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
        case .removeSubscriptions:
            return cleanup()
        case .alertDismissButtonTapped:
            state.loadingState = .idle
            return .none
        case let .showCardWallReceived(cardWallState):
            state.cardWallState = cardWallState
            return .none
        case .dismissCardWall, .cardWall(action: .close):
            state.cardWallState = nil
            return .concatenate(
                CardWallDomain.cleanup(),
                Effect(value: .loadRemoteGroupedPrescriptionsAndSave)
            )
        case .cardWall, .hint:
            return .none

        // details view
        case let .prescriptionDetailViewTapped(erxTask):
            state.selectedPrescriptionDetailState = PrescriptionDetailDomain.State(
                erxTask: erxTask,
                isRedeemed: erxTask.redeemedOn != nil
            )
            return .none
        case .dismissPrescriptionDetailView, .prescriptionDetailAction(.close):
            state.selectedPrescriptionDetailState = nil
            return PrescriptionDetailDomain.cleanup()
        case let .prescriptionDetailAction(action):
            return .none

        // redeem view
        case let .redeemViewTapped(selectedGroupedPrescription):
            state.redeemState = RedeemDomain.State(
                groupedPrescription: selectedGroupedPrescription
            )
            return .none
        case .dismissRedeemView, .redeemView(action: .close):
            state.redeemState = nil
            return RedeemDomain.cleanup()
        case .redeemView(action:):
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        prescriptionDetailPullbackReducer,
        redeemViewPullbackReducer,
        cardWallPullbackReducer,
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

    static let prescriptionDetailPullbackReducer: Reducer =
        PrescriptionDetailDomain.reducer.optional().pullback(
            state: \.selectedPrescriptionDetailState,
            action: /GroupedPrescriptionListDomain.Action.prescriptionDetailAction(action:)
        ) { environment in
            PrescriptionDetailDomain.Environment(
                schedulers: environment.schedulers,
                locationManager: .live,
                taskRepositoryAccess: environment.userSession.erxTaskRepository,
                fhirDateFormatter: environment.fhirDateFormatter
            )
        }

    static let redeemViewPullbackReducer: Reducer =
        RedeemDomain.reducer.optional().pullback(
            state: \.redeemState,
            action: /GroupedPrescriptionListDomain.Action.redeemView(action:)
        ) { environment in
            RedeemDomain.Environment(
                schedulers: environment.schedulers,
                userSession: environment.userSession,
                fhirDateFormatter: environment.fhirDateFormatter,
                locationManager: .live
            )
        }

    static let cardWallPullbackReducer: Reducer =
        CardWallDomain.reducer
            .optional()
            .pullback(
                state: \.cardWallState,
                action: /GroupedPrescriptionListDomain.Action.cardWall(action:)
            ) { globalEnvironment in
                CardWallDomain.Environment(
                    schedulers: globalEnvironment.schedulers,
                    userSession: globalEnvironment.userSession,
                    signatureProvider: globalEnvironment.signatureProvider,
                    accessibilityAnnouncementReceiver: globalEnvironment.accessibilityAnnouncementReceiver
                )
            }
}

extension GroupedPrescriptionListDomain.Environment {
    func cardWall() -> AnyPublisher<CardWallDomain.State, Never> {
        let hideCardWallIntro = userSession.localUserStore.hideCardWallIntro
        let canAvailable = userSession.secureUserStore.can

        return canAvailable
            .combineLatest(hideCardWallIntro)
            .first()
            .map { can, hideCardWallIntro in
                CardWallDomain.State(
                    introAlreadyDisplayed: hideCardWallIntro,
                    isNFCReady: serviceLocator.deviceCapabilities.isNFCReady,
                    isMinimalOS14: serviceLocator.deviceCapabilities.isMinimumOS14,
                    can: (can != nil) ? nil : CardWallCANDomain.State(
                        isDemoModus: self.userSession.isDemoMode,
                        can: ""
                    ),
                    pin: CardWallPINDomain.State(isDemoModus: self.userSession.isDemoMode, pin: ""),
                    loginOption: CardWallLoginOptionDomain.State(isDemoModus: self.userSession.isDemoMode)
                )
            }
            .eraseToAnyPublisher()
    }

    func loadRemoteTasksAndSave()
        -> Effect<LoadingState<[GroupedPrescription], ErxTaskRepositoryError>, Never> {
        userSession
            .isAuthenticated
            .mapError { ErxTaskRepositoryError.local(.initialization(error: $0)) }
            .first()
            .flatMap { isAuthenticated
                -> AnyPublisher<[GroupedPrescription], ErxTaskRepositoryError> in

                if isAuthenticated {
                    return
                        groupedPrescriptionStore
                        .loadRemoteAndSave(for: locale)
                            .first()
                            .eraseToAnyPublisher()
                } else {
                    // return so the loadingState can be updated
                    return Just([])
                        .setFailureType(to: ErxTaskRepositoryError.self)
                        .eraseToAnyPublisher()
                }
            }
            .map(LoadingState<[GroupedPrescription], ErxTaskRepositoryError>.value)
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
                    // TODO: error type mapping is bogus // swiftlint:disable:this todo
                    return Just(GroupedPrescriptionListDomain.Action
                        .loadRemoteGroupedPrescriptionsAndSaveReceived(
                            LoadingState.error(ErxTaskRepositoryError.local(.initialization(error: error)))
                        ))
                        .eraseToEffect()

//                    switch error {
//                    case .biometrieFatal:
//                    case .biometrieFailed:
//                        Just(GroupedPrescriptionListDomain.Action
//                            .loadRemoteGroupedPrescriptionsAndSaveReceived(LoadingState.error(error)))
//                    case .biometrieFatal:
//                        <#code#>
//                    case .ssoFailed:
//                        <#code#>
//                    case .ssoExpired:
//                        <#code#>
//                    }
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

extension Publisher where Output == GroupedPrescriptionListDomain.Action, Failure == ErxTaskRepositoryError {
    /// Catches "forbidden"/403 server response to show card wall. The acutual invalidation of any token is communicated
    /// within IDPInterceptor.
    ///
    /// - Parameter environment: The environment of the Screen
    /// - Returns: A Publisher that catches 403 server responses and transforms them into `showCardWallReceived`
    /// actions.
    func catchUnauthorizedToShowCardwall(
        in environment: GroupedPrescriptionListDomain.Environment
    )
    -> AnyPublisher<GroupedPrescriptionListDomain.Action, ErxTaskRepositoryError> {
        tryCatch { (error: ErxTaskRepositoryError) -> AnyPublisher<
            GroupedPrescriptionListDomain.Action,
            ErxTaskRepositoryError
        > in
            if case let ErxTaskRepositoryError.remote(.fhirClientError(.httpError(.httpError(urlError)))) = error,
               urlError.code.rawValue == 403 || urlError.code.rawValue == 401 {
                return environment.cardWall()
                    .receive(on: environment.schedulers.main.animation())
                    .map(GroupedPrescriptionListDomain.Action.showCardWallReceived)
                    .setFailureType(to: ErxTaskRepositoryError.self)
                    .eraseToAnyPublisher()
            }
            throw error as ErxTaskRepositoryError
        }
        .mapError { $0 as! ErxTaskRepositoryError } // swiftlint:disable:this force_cast
        .eraseToAnyPublisher()
    }
}

extension GroupedPrescriptionListDomain {
    enum Dummies {
        static let demoSessionContainer = ChangeableUserSessionContainer(
            initialUserSession: DemoSessionContainer(),
            schedulers: Schedulers()
        )
        static let state = State()
        static let stateWithTwoPrescriptions = State(
            loadingState: .value([GroupedPrescription.Dummies.twoPrescriptions]),
            cardWallState: nil,
            groupedPrescriptions: [GroupedPrescription.Dummies.twoPrescriptions],
            selectedPrescriptionDetailState: nil,
            redeemState: nil,
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
            signatureProvider: DummySecureEnclaveSignatureProvider()
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
