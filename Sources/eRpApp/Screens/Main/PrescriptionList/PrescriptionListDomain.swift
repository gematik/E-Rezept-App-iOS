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
import FHIRClient
import Foundation
import HTTPClient
import IDP

@Reducer
struct PrescriptionListDomain {
    enum CancelID: CaseIterable, Hashable {
        case loadLocalPrescriptionId
        case fetchPrescriptionId
        case refreshId
        case selectedProfileId
        case activeUserProfile
    }

    @ObservableState
    struct State: Equatable {
        var loadingState: LoadingState<[Prescription], PrescriptionRepositoryError>
        var prescriptions: [Prescription] {
            didSet {
                openPrescriptions = prescriptions.filter { !$0.isArchived }
                hasArchivedPrescriptions = openPrescriptions.count != prescriptions.count
            }
        }

        private(set) var openPrescriptions: [Prescription] = []
        private(set) var hasArchivedPrescriptions = false

        var profile: UserProfile?

        var showError: Bool {
            loadingState.error != nil
        }

        var isConnected: Bool {
            profile?.connectionStatus == .connected
        }

        init(
            loadingState: LoadingState<[Prescription], PrescriptionRepositoryError> = .idle,
            prescriptions: [Prescription] = [],
            hasArchivedPrescriptions _: Bool = false,
            profile: UserProfile? = nil
        ) {
            self.loadingState = loadingState
            self.prescriptions = prescriptions
            let openPrescriptions = prescriptions.filter { !$0.isArchived }
            self.openPrescriptions = openPrescriptions
            hasArchivedPrescriptions = openPrescriptions.count != prescriptions.count
            self.profile = profile
        }
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
            locale: Locale.current.language.languageCode?.identifier ?? "de"
        )
    }

    var body: some Reducer<State, Action> {
        Reduce(self.core)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .registerSelectedProfileIDListener:
            return .publisher(
                userProfileService.selectedProfileId
                    .removeDuplicates()
                    .map { .response(.selectedProfileIDReceived($0)) }
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case .unregisterSelectedProfileIDListener:
            return .cancel(id: CancelID.selectedProfileId)
        case .response(.selectedProfileIDReceived):
            return .concatenate(
                Effect.send(.loadLocalPrescriptions),
                Effect.send(.loadRemotePrescriptionsAndSave)
            )
        case .unregisterActiveUserProfileListener:
            return .cancel(id: CancelID.activeUserProfile)
        case .registerActiveUserProfileListener:
            return .publisher(
                userProfileService.activeUserProfilePublisher()
                    .catchToPublisher()
                    .map { .response(.activeUserProfileReceived($0)) }
                    .receive(on: schedulers.main)
                    .eraseToAnyPublisher
            )
        case .response(.activeUserProfileReceived(.failure)):
            state.profile = nil
            return .none
        case let .response(.activeUserProfileReceived(.success(profile))):
            state.profile = profile
            return .none
        case .loadLocalPrescriptions:
            state.loadingState = .loading(state.prescriptions)
            return .publisher(
                prescriptionRepository.loadLocal()
                    .receive(on: schedulers.main.animation())
                    .catchToLoadingStateEffect()
                    .map { Action.response(.loadLocalPrescriptionsReceived($0)) }
                    .eraseToAnyPublisher
            )
            .cancellable(id: CancelID.loadLocalPrescriptionId, cancelInFlight: true)
        case let .response(.loadLocalPrescriptionsReceived(loadingState)):
            state.loadingState = loadingState
            state.prescriptions = loadingState.value ?? []
            return .none
        case .loadRemotePrescriptionsAndSave:
            state.loadingState = .loading(nil)
            return environment.loadRemoteTasksAndSave()
                .cancellable(id: CancelID.fetchPrescriptionId, cancelInFlight: true)
        case let .response(.loadRemotePrescriptionsAndSaveReceived(loadingState)):
            state.loadingState = loadingState
            // prevent overriding values previously loaded from .loadLocalPrescriptions
            if case let .value(prescriptions) = loadingState, !prescriptions.isEmpty {
                state.prescriptions = prescriptions
            }
            return .none
        case .refresh:
            state.loadingState = .loading(nil)
            return environment.refreshOrShowCardWall().cancellable(id: CancelID.refreshId, cancelInFlight: true)
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

extension PrescriptionListDomain {
    struct Environment {
        var schedulers: Schedulers
        var serviceLocator: ServiceLocator
        var userSession: UserSession
        var userProfileService: UserProfileService
        var prescriptionRepository: PrescriptionRepository
        var locale: String?

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
        func loadRemoteTasksAndSave() -> Effect<PrescriptionListDomain.Action> {
            .publisher(
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
                    .eraseToAnyPublisher
            )
        }

        /// Load ErxTasks if already logged in else show CardWall or error
        func refreshOrShowCardWall() -> Effect<PrescriptionListDomain.Action> {
            .publisher(
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
                    .eraseToAnyPublisher
            )
        }
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
            .erxRepository(.remote(.fhirClient(FHIRClient.Error.http(fhirClientHttpError)))) = error,
            case let .httpError(urlError) = fhirClientHttpError.httpClientError,
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

        static let store = Store(
            initialState: state
        ) {
            PrescriptionListDomain()
        }

        static func storeFor(_ state: State) -> StoreOf<PrescriptionListDomain> {
            Store(
                initialState: state
            ) {
                PrescriptionListDomain()
            }
        }
    }
}
