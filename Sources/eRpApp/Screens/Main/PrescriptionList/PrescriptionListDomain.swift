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

struct PrescriptionListDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    /// Provides an Effect that need to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
    }

    enum Token: CaseIterable, Hashable {
        case loadLocalPrescriptionId
        case fetchPrescriptionId
        case refreshId
        case selectedProfileId
        case activeUserProfile
    }

    struct State: Equatable {
        var loadingState: LoadingState<[Prescription], PrescriptionRepositoryError> =
            .idle
        var prescriptions: [Prescription] = []
        var profile: UserProfile?
    }

    enum Action: Equatable {
        /// Loads locally stored Prescriptions
        case loadLocalPrescriptions
        ///  Loads Prescriptions from server and stores them in the local store
        case loadRemotePrescriptionsAndSave
        /// Presents the CardWall when not logged in or executes `loadFromCloudAndSave`
        case refresh
        /// Listener for selectedProfileID switches
        case registerSelectedProfileIDListener
        case unregisterSelectedProfileIDListener
        /// Listener for active UserProfile update changes (including connectivity status, activity status)
        case registerActiveUserProfileListener
        case unregisterActiveUserProfileListener
        case showArchivedButtonTapped
        case profilePictureViewTapped(UserProfile)
        /// Dismisses the alert that showing loading errors
        case alertDismissButtonTapped
        /// Details actions
        case prescriptionDetailViewTapped(selectedPrescription: Prescription)
        /// Redeem actions
        case redeemButtonTapped(openPrescriptions: [Prescription])

        case response(Response)

        enum Response: Equatable {
            /// Response from `loadLocalPrescriptions`
            case loadLocalPrescriptionsReceived(LoadingState<[Prescription], PrescriptionRepositoryError>)
            /// Response from `loadRemotePrescriptionsAndSave`
            case loadRemotePrescriptionsAndSaveReceived(LoadingState<[Prescription], PrescriptionRepositoryError>)
            case selectedProfileIDReceived(UUID?)
            case activeUserProfileReceived(Result<UserProfile, UserProfileServiceError>)
            /// Response from `refresh` that presents the CardWall sheet
            case showCardWallReceived(CardWallIntroductionDomain.State)
            case errorReceived(LoginHandlerError)
        }
    }

    /// To make sure enough time is left to redeem prescriptions we define a minimum
    /// number of minutes that need to be left before the session expires.
    let minLoginTimeLeftInMinutes: Int = 29

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.serviceLocator) var serviceLocator: ServiceLocator
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.userProfileService) var userProfileService: UserProfileService
    @Dependency(\.prescriptionRepository) var prescriptionRepository: PrescriptionRepository

    private var environment: Environment {
        .init(
            schedulers: schedulers,
            serviceLocator: serviceLocator,
            userSession: userSession,
            userProfileService: userProfileService,
            prescriptionRepository: prescriptionRepository,
            locale: Locale.current.languageCode
        )
    }

    struct Environment {
        var schedulers: Schedulers
        var serviceLocator: ServiceLocator
        var userSession: UserSession
        var userProfileService: UserProfileService
        var prescriptionRepository: PrescriptionRepository
        var locale: String?
    }

    init() {}

    var body: some ReducerProtocol<State, Action> {
        Reduce(self.core)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func core(state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .registerSelectedProfileIDListener:
            return userProfileService.selectedProfileId
                .removeDuplicates()
                .map { .response(.selectedProfileIDReceived($0)) }
                .receive(on: schedulers.main)
                .eraseToEffect()
                .cancellable(id: Token.selectedProfileId)
        case .unregisterSelectedProfileIDListener:
            return .cancel(id: Token.selectedProfileId)
        case .response(.selectedProfileIDReceived):
            return .concatenate(
                EffectTask(value: .loadLocalPrescriptions),
                EffectTask(value: .loadRemotePrescriptionsAndSave)
            )

        case .unregisterActiveUserProfileListener:
            return .cancel(id: Token.activeUserProfile)
        case .registerActiveUserProfileListener:
            return userProfileService.activeUserProfilePublisher()
                .catchToEffect()
                .map { .response(.activeUserProfileReceived($0)) }
                .cancellable(id: Token.activeUserProfile, cancelInFlight: true)
                .receive(on: schedulers.main)
                .eraseToEffect()
        case .response(.activeUserProfileReceived(.failure)):
            state.profile = nil
            return .none
        case let .response(.activeUserProfileReceived(.success(profile))):
            state.profile = profile
            return .none
        case .loadLocalPrescriptions:
            state.loadingState = .loading(state.prescriptions)
            return prescriptionRepository.loadLocal()
                .receive(on: schedulers.main.animation())
                .catchToLoadingStateEffect()
                .map { .response(.loadLocalPrescriptionsReceived($0)) }
                .cancellable(id: Token.loadLocalPrescriptionId, cancelInFlight: true)
        case let .response(.loadLocalPrescriptionsReceived(loadingState)):
            state.loadingState = loadingState
            state.prescriptions = loadingState.value ?? []
            return .none
        case .loadRemotePrescriptionsAndSave:
            state.loadingState = .loading(nil)
            return environment.loadRemoteTasksAndSave()
                .cancellable(id: Token.fetchPrescriptionId, cancelInFlight: true)
        case let .response(.loadRemotePrescriptionsAndSaveReceived(loadingState)):
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
        case .response(.showCardWallReceived),
             .prescriptionDetailViewTapped,
             .redeemButtonTapped,
             .showArchivedButtonTapped,
             .profilePictureViewTapped:
            return .none
        case .response(.errorReceived):
            state.loadingState = .idle
            return .none // Handled in parent domain
        }
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
    func loadRemoteTasksAndSave() -> EffectTask<PrescriptionListDomain.Action> {
        prescriptionRepository
            .silentLoadRemote(for: locale)
            .map { status -> PrescriptionListDomain.Action in
                switch status {
                case let .prescriptions(value):
                    return .response(.loadRemotePrescriptionsAndSaveReceived(.value(value)))
                case .notAuthenticated,
                     .authenticationRequired:
                    return .response(.loadRemotePrescriptionsAndSaveReceived(.value([])))
                }
            }
            .catch { _ in Just(.response(.loadRemotePrescriptionsAndSaveReceived(.idle))) }
            .receive(on: schedulers.main.animation())
            .eraseToEffect()
    }

    /// Load ErxTasks if already logged in else show CardWall or error
    func refreshOrShowCardWall() -> EffectTask<PrescriptionListDomain.Action> {
        prescriptionRepository
            .forcedLoadRemote(for: locale)
            .catchUnauthorizedToShowCardwall()
            .flatMap { status -> AnyPublisher<PrescriptionListDomain.Action, PrescriptionRepositoryError> in
                switch status {
                case let .prescriptions(value):
                    return Just(.response(.loadRemotePrescriptionsAndSaveReceived(.value(value))))
                        .setFailureType(to: PrescriptionRepositoryError.self)
                        .eraseToAnyPublisher()
                case .notAuthenticated,
                     .authenticationRequired:
                    return cardWall()
                        .receive(on: schedulers.main)
                        .setFailureType(to: PrescriptionRepositoryError.self)
                        .map { .response(.showCardWallReceived($0)) }
                        .eraseToAnyPublisher()
                }
            }
            .catch { error in
                if case let PrescriptionRepositoryError.loginHandler(error) = error {
                    return Just(Action.response(.errorReceived(error)))
                        .eraseToAnyPublisher()
                }
                return Just(Action.response(.loadRemotePrescriptionsAndSaveReceived(.error(error))))
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
        static let state = State()
        static let stateWithPrescriptions = State(
            loadingState: .value(Prescription.Dummies.prescriptions),
            prescriptions: Prescription.Dummies.prescriptions,
            profile: UserProfile.Dummies.profileA
        )

        static let store = Store(initialState: state,
                                 reducer: PrescriptionListDomain())

        static func storeFor(_ state: State) -> Store {
            Store(initialState: state,
                  reducer: PrescriptionListDomain())
        }
    }
}
