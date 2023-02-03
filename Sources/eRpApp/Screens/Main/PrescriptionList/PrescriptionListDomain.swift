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
import FHIRClient
import Foundation
import HTTPClient
import IDP

enum PrescriptionListDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.AnyReducer<State, Action, Environment>

    /// Provides an Effect that need to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(id: Token.self)
    }

    enum Token: CaseIterable, Hashable {
        case loadLocalPrescriptionId
        case fetchPrescriptionId
        case refreshId
        case selectedProfileId
        case activeUserProfile
    }

    struct Environment {
        let router: Routing
        let userSession: UserSession
        let userProfileService: UserProfileService
        let serviceLocator: ServiceLocator
        let accessibilityAnnouncementReceiver: (String) -> Void
        let prescriptionRepository: PrescriptionRepository
        let schedulers: Schedulers
        var fhirDateFormatter: FHIRDateFormatter
        /// To make sure enough time is left to redeem prescriptions we define a minimum
        /// number of minutes that need to be left before the session expires.
        let minLoginTimeLeftInMinutes: Int = 29

        var locale: String? {
            Locale.current.languageCode
        }
    }

    struct State: Equatable {
        var loadingState: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .idle
        var prescriptions: [Prescription] = []
        var profile: UserProfile?

        var hintState = MainViewHintsDomain.State()
    }

    enum Action: Equatable {
        /// Loads locally stored Prescriptions
        case loadLocalPrescriptions
        /// Response from `loadLocalPrescriptions`
        case loadLocalPrescriptionsReceived(LoadingState<[Prescription], PrescriptionRepositoryError>)
        ///  Loads Prescriptions from server and stores them in the local store
        case loadRemotePrescriptionsAndSave
        /// Response from `loadRemotePrescriptionsAndSave`
        case loadRemotePrescriptionsAndSaveReceived(LoadingState<[Prescription], PrescriptionRepositoryError>)
        /// Presents the CardWall when not logged in or executes `loadFromCloudAndSave`
        case refresh
        /// Listener for selectedProfileID switches
        case registerSelectedProfileIDListener
        case unregisterSelectedProfileIDListener
        case selectedProfileIDReceived(UUID?)
        /// Listener for active UserProfile update changes (including connectivity status, activity status)
        case registerActiveUserProfileListener
        case unregisterActiveUserProfileListener
        case activeUserProfileReceived(Result<UserProfile, UserProfileServiceError>)

        case showArchivedButtonTapped
        case profilePictureViewTapped

        /// Dismisses the alert that showing loading errors
        case alertDismissButtonTapped
        /// Response from `refresh` that presents the CardWall sheet
        case showCardWallReceived(CardWallIntroductionDomain.State)

        /// Details actions
        case prescriptionDetailViewTapped(selectedPrescription: Prescription)

        /// Redeem actions
        case redeemButtonTapped(openPrescriptions: [Prescription])

        /// Actions related to hint
        case hint(action: MainViewHintsDomain.Action)

        case errorReceived(LoginHandlerError)
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .registerSelectedProfileIDListener:
            return environment.userProfileService.selectedProfileId
                .removeDuplicates()
                .map(Action.selectedProfileIDReceived)
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
                .cancellable(id: Token.selectedProfileId)
        case .unregisterSelectedProfileIDListener:
            return .cancel(id: Token.selectedProfileId)
        case let .selectedProfileIDReceived(uuid):
            return .concatenate(
                Effect(value: .loadLocalPrescriptions),
                Effect(value: .loadRemotePrescriptionsAndSave)
            )

        case .unregisterActiveUserProfileListener:
            return .cancel(id: Token.activeUserProfile)
        case .registerActiveUserProfileListener:
            return environment.userProfileService.activeUserProfilePublisher()
                .catchToEffect()
                .map(Action.activeUserProfileReceived)
                .cancellable(id: Token.activeUserProfile, cancelInFlight: true)
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case .activeUserProfileReceived(.failure):
            state.profile = nil
            return .none
        case let .activeUserProfileReceived(.success(profile)):
            state.profile = profile
            return .none
        case .loadLocalPrescriptions:
            state.loadingState = .loading(state.prescriptions)
            return environment.prescriptionRepository.loadLocal()
                .receive(on: environment.schedulers.main.animation())
                .catchToLoadingStateEffect()
                .map(Action.loadLocalPrescriptionsReceived)
                .cancellable(id: Token.loadLocalPrescriptionId, cancelInFlight: true)
        case let .loadLocalPrescriptionsReceived(loadingState):
            state.loadingState = loadingState
            state.prescriptions = loadingState.value ?? []
            return .none
        case .loadRemotePrescriptionsAndSave:
            state.loadingState = .loading(nil)
            return environment.loadRemoteTasksAndSave()
                .cancellable(id: Token.fetchPrescriptionId, cancelInFlight: true)
        case let .loadRemotePrescriptionsAndSaveReceived(loadingState):
            state.loadingState = loadingState
            // prevent overriding values previously loaded from .loadLocalPrescriptions
            if case let .value(prescriptions) = loadingState, !prescriptions.isEmpty {
                state.prescriptions = prescriptions
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
             .redeemButtonTapped,
             .showArchivedButtonTapped,
             .profilePictureViewTapped:
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
                action: /PrescriptionListDomain.Action.hint(action:)
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

extension PrescriptionListDomain.Environment {
    typealias Action = PrescriptionListDomain.Action

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

    /// "Silently" try to load ErxTasks if preconditions are met
    func loadRemoteTasksAndSave() -> Effect<PrescriptionListDomain.Action, Never> {
        prescriptionRepository
            .silentLoadRemote(for: locale)
            .map { status -> PrescriptionListDomain.Action in
                switch status {
                case let .prescriptions(value):
                    return .loadRemotePrescriptionsAndSaveReceived(.value(value))
                case .notAuthenticated,
                     .authenticationRequired:
                    return .loadRemotePrescriptionsAndSaveReceived(.value([]))
                }
            }
            .catch { _ in Just(.loadRemotePrescriptionsAndSaveReceived(.idle)) }
            .receive(on: schedulers.main.animation())
            .eraseToEffect()
    }

    /// Load ErxTasks if already logged in else show CardWall or error
    func refreshOrShowCardWall() -> Effect<PrescriptionListDomain.Action, Never> {
        prescriptionRepository
            .forcedLoadRemote(for: locale)
            .catchUnauthorizedToShowCardwall()
            .flatMap { status -> AnyPublisher<PrescriptionListDomain.Action, PrescriptionRepositoryError> in
                switch status {
                case let .prescriptions(value):
                    return Just(.loadRemotePrescriptionsAndSaveReceived(.value(value)))
                        .setFailureType(to: PrescriptionRepositoryError.self)
                        .eraseToAnyPublisher()
                case .notAuthenticated,
                     .authenticationRequired:
                    return cardWall()
                        .receive(on: schedulers.main)
                        .setFailureType(to: PrescriptionRepositoryError.self)
                        .map(PrescriptionListDomain.Action.showCardWallReceived)
                        .eraseToAnyPublisher()
                }
            }
            .catch { error in
                if case let PrescriptionRepositoryError.loginHandler(error) = error {
                    return Just(Action.errorReceived(error))
                        .eraseToAnyPublisher()
                }
                return Just(Action.loadRemotePrescriptionsAndSaveReceived(.error(error)))
                    .eraseToAnyPublisher()
            }
            .receive(on: schedulers.main)
            .eraseToEffect()
    }
}

extension Publisher where Output == PrescriptionRepositoryLoadRemoteResult, Failure == PrescriptionRepositoryError {
    /// Catches "forbidden"/403 server response to show card wall. The actual invalidation of any token is communicated
    /// within IDPInterceptor.
    ///
    /// - Parameter environment: The environment of the Screen
    /// - Returns: A Publisher that catches 403 server responses and transforms them into `showCardWallReceived`
    /// actions.
    func catchUnauthorizedToShowCardwall()
        -> AnyPublisher<PrescriptionRepositoryLoadRemoteResult, PrescriptionRepositoryError> {
        self.catch { (error: PrescriptionRepositoryError) -> AnyPublisher<
            PrescriptionRepositoryLoadRemoteResult,
            PrescriptionRepositoryError
        > in
        if case let PrescriptionRepositoryError
            .erxRepository(.remote(.fhirClientError(FHIRClient.Error.httpError(.httpError(urlError))))) = error,
            urlError.code.rawValue == HTTPStatusCode.forbidden.rawValue ||
            urlError.code.rawValue == HTTPStatusCode.unauthorized.rawValue {
            return Just(PrescriptionRepositoryLoadRemoteResult.authenticationRequired)
                .setFailureType(to: PrescriptionRepositoryError.self)
                .eraseToAnyPublisher()
        }
        return Fail(error: error).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

extension PrescriptionListDomain {
    enum Dummies {
        static let demoSessionContainer = DummyUserSessionContainer()
        static let state = State()
        static let stateWithTwoPrescriptions = State(
            loadingState: .value(Prescription.Dummies.prescriptions),
            prescriptions: Prescription.Dummies.prescriptions,
            profile: UserProfile.Dummies.profileA,
            hintState: MainViewHintsDomain.Dummies.emptyState()
        )

        static let environment = Environment(
            router: DummyRouter(),
            userSession: demoSessionContainer.userSession,
            userProfileService: DummyUserProfileService(),
            serviceLocator: ServiceLocator(),
            accessibilityAnnouncementReceiver: { _ in },
            prescriptionRepository: DummyPrescriptionRepository(),
            schedulers: Schedulers(),
            fhirDateFormatter: FHIRDateFormatter.shared
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
