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
import Foundation
import IDP

enum MainDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    enum Route: Equatable {
        case addProfile(AddProfileDomain.State)
        case scanner(ScannerDomain.State)
        case deviceSecurity(DeviceSecurityDomain.State)
        case cardWall(CardWallIntroductionDomain.State)
        case prescriptionDetail(PrescriptionDetailDomain.State)
        case redeem(RedeemMethodsDomain.State)
        case alert(ErpAlertState<Action>)
    }

    struct State: Equatable {
        var prescriptionListState: PrescriptionListDomain.State
        var extAuthPendingState = ExtAuthPendingDomain.State()
        var horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State
        var isDemoMode = false
        var route: Route?
    }

    /// Provides an Effect that need to run whenever the state of this Domain is reset to nil
    static func cleanup<T>() -> Effect<T, Never> {
        .concatenate(
            Effect.cancel(token: Token.self),
            cleanupSubDomains()
        )
    }

    private static func cleanupSubDomains<T>() -> Effect<T, Never> {
        .concatenate(
            DeviceSecurityDomain.cleanup(),
            CardWallIntroductionDomain.cleanup(),
            PrescriptionDetailDomain.cleanup(),
            RedeemMethodsDomain.cleanup()
        )
    }

    enum Token: CaseIterable, Hashable {
        case demoMode
        case checkForTaskDuplicates
    }

    enum Action: Equatable {
        /// Presents the `ScannerView`
        case showScannerView
        /// Hides the `ScannerView`
        case loadDeviceSecurityView
        case loadDeviceSecurityViewReceived(DeviceSecurityDomain.State?)
        /// Start listening to demo mode changes
        case subscribeToDemoModeChange
        case unsubscribeFromDemoModeChange
        case demoModeChangeReceived(Bool)
        /// Tapping the demo mode banner can also turn the demo mode off
        case turnOffDemoMode
        case externalLogin(URL)
        case importTaskByUrl(URL)
        case extAuthPending(action: ExtAuthPendingDomain.Action)
        case importReceived(Result<[ErxTask], Error>)
        case setNavigation(tag: Route.Tag?)
        case horizontalProfileSelection(action: HorizontalProfileSelectionDomain.Action)
        // Child Domain Actions
        /// Child view actions for the `PrescriptionListDomain`
        case prescriptionList(action: PrescriptionListDomain.Action)
        /// Child view actions for the `ScannerDomain`
        case scanner(action: ScannerDomain.Action)
        case deviceSecurity(action: DeviceSecurityDomain.Action)
        case prescriptionDetailAction(action: PrescriptionDetailDomain.Action)
        case redeemMethods(action: RedeemMethodsDomain.Action)
        case cardWall(action: CardWallIntroductionDomain.Action)
        case refreshPrescription
        case addProfileAction(action: AddProfileDomain.Action)
    }
    // sourcery: CodedError = "015"
    enum Error: Swift.Error, Equatable {
        // sourcery: errorCode = "01"
        case localStoreError(LocalStoreError)
        // sourcery: errorCode = "02"
        case userSessionError(UserSessionError)
        // sourcery: errorCode = "03"
        /// Import of shared Task failed due to being a duplicate already existing within the app
        case importDuplicate
        // sourcery: errorCode = "04"
        /// Saving or retrieving data failed
        case repositoryError(ErxRepositoryError)
    }

    struct Environment {
        let router: Routing
        var userSessionContainer: UsersSessionContainer
        var userSession: UserSession
        let appSecurityManager: AppSecurityManager
        var serviceLocator: ServiceLocator
        let accessibilityAnnouncementReceiver: (String) -> Void
        var erxTaskRepository: ErxTaskRepository
        var schedulers: Schedulers
        var fhirDateFormatter: FHIRDateFormatter
        let userProfileService: UserProfileService
        let secureDataWiper: ProfileSecureDataWiper
        var signatureProvider: SecureEnclaveSignatureProvider
        var userSessionProvider: UserSessionProvider
        var userDataStore: UserDataStore
        let tracker: Tracker
    }
}

extension MainDomain {
    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .showScannerView:
            state.route = .scanner(ScannerDomain.State())
            return .none
        case .scanner(action: .close):
            state.route = nil
            return ScannerDomain.cleanup()
        case .turnOffDemoMode:
            environment.router.routeTo(.settings)
            return .none
        case .loadDeviceSecurityView:
            return environment.userSession.deviceSecurityManager.showSystemSecurityWarning
                .map { type in
                    switch type {
                    case .none:
                        return nil
                    default:
                        return DeviceSecurityDomain.State(warningType: type)
                    }
                }
                .map(Action.loadDeviceSecurityViewReceived)
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case let .loadDeviceSecurityViewReceived(deviceSecurityState):
            if let deviceSecurityState = deviceSecurityState {
                state.route = .deviceSecurity(deviceSecurityState)
            }
            return .none
        case .subscribeToDemoModeChange:
            return environment.userSessionContainer.isDemoMode
                .map(MainDomain.Action.demoModeChangeReceived)
                .receive(on: environment.schedulers.main.animation())
                .eraseToEffect()
                .cancellable(id: Token.demoMode)
        case let .demoModeChangeReceived(demoModeValue):
            state.isDemoMode = demoModeValue
            return .none
        case .unsubscribeFromDemoModeChange:
            return cleanup()
        case .deviceSecurity(.close):
            state.route = nil
            return cleanupSubDomains()
        case let .externalLogin(url):
            return Effect(value: .extAuthPending(action: .externalLogin(url)))
                .delay(for: 5, scheduler: environment.schedulers.main)
                .eraseToEffect()
        case let .importTaskByUrl(url):
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  components.path.contains("prescription"),
                  let fragment = components.fragment?.data(using: .utf8),
                  let sharedTasks = try? JSONDecoder().decode([SharedTask].self, from: fragment) else {
                return .none
            }
            return environment.checkForTaskDuplicatesThenSave(sharedTasks)
                .cancellable(id: Token.checkForTaskDuplicates)
        case .importReceived(.success):
            state.route = .alert(.init(title: TextState(L10n.erxTxtPrescriptionAddedAlertTitle.text)))
            return .none
        case let .importReceived(.failure(error)):
            state.route = .alert(.init(for: error, title: L10n.erxTxtPrescriptionDuplicateAlertTitle))
            return .none
        case .setNavigation(tag: .none):
            state.route = nil
            return cleanupSubDomains()
        case .setNavigation(tag: .cardWall):
            state.route = .cardWall(.init(isNFCReady: true, profileId: environment.userSession.profileId))
            return .none
        case let .prescriptionList(action: .errorReceived(error)):
            let alertState: ErpAlertState<Action>
            switch error {
            case .idpError(.biometrics) where error.contains(PrivateKeyContainer.Error.canceledByUser):
                alertState = .init(for: error, title: L10n.errSpecificI10808Title)
            case .idpError(.biometrics), .idpError(.serverError):
                alertState = .init(
                    for: error,
                    title: L10n.errTitleLoginNecessary,
                    primaryButton: .default(
                        TextState(L10n.erxBtnAlertLogin),
                        action: .send(Action.setNavigation(tag: .cardWall))
                    )
                )
            default:
                alertState = .init(for: error)
            }
            state.route = .alert(alertState)
            return .none
        case let .prescriptionList(action: .showCardWallReceived(cardWallState)):
            state.route = .cardWall(cardWallState)
            return .none
        case let .prescriptionList(action: .prescriptionDetailViewTapped(prescription)):
            state.route = .prescriptionDetail(PrescriptionDetailDomain.State(
                prescription: prescription,
                isArchived: prescription.isArchived
            ))
            return .none
        case let .prescriptionList(action: .redeemViewTapped(selectedGroupedPrescription)):
            state.route = .redeem(
                RedeemMethodsDomain.State(erxTasks: selectedGroupedPrescription.redeemablePrescriptions.map(\.erxTask))
            )
            return .none
        case .cardWall(action: .close):
            state.route = nil
            return .concatenate(
                CardWallIntroductionDomain.cleanup(),
                Effect(value: .prescriptionList(action: .loadRemoteGroupedPrescriptionsAndSave))
            )
        case .redeemMethods(action: .close),
             .prescriptionDetailAction(action: .close),
             .addProfileAction(action: .close):
            state.route = nil
            return cleanupSubDomains()
        case let .horizontalProfileSelection(action: .loadReceived(.failure(error))):
            state.route = .alert(.init(for: error))
            return .none
        case .refreshPrescription:
            return Effect(value: .prescriptionList(action: .refresh))
        case .horizontalProfileSelection(action: .showAddProfileView):
            state.route = .addProfile(AddProfileDomain.State())
            return .none
        case .deviceSecurity,
             .setNavigation,
             .prescriptionList,
             .scanner,
             .extAuthPending,
             .redeemMethods,
             .cardWall,
             .horizontalProfileSelection,
             .prescriptionDetailAction,
             .addProfileAction:
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        prescriptionListPullback,
        scannerPullbackReducer,
        deviceSecurityPullbackReducer,
        prescriptionDetailPullbackReducer,
        redeemMethodsPullbackReducer,
        cardWallPullbackReducer,
        extAuthPendingReducer,
        horizontalProfileSelectionReducer,
        addProfilePullbackReducer,
        domainReducer
    )
}

extension MainDomain.Environment {
    func checkForTaskDuplicatesThenSave(_ sharedTasks: [SharedTask]) -> Effect<MainDomain.Action, Never> {
        let authoredOn = fhirDateFormatter.stringWithLongUTCTimeZone(from: Date())
        let erxTaskRepository = self.erxTaskRepository

        return checkForTaskDuplicatesInStore(sharedTasks)
            .flatMap { tasks -> AnyPublisher<[ErxTask], MainDomain.Error> in
                let erxTasks = tasks.asErxTasks(
                    status: .ready,
                    with: authoredOn,
                    author: L10n.scnTxtAuthor.text
                ) { L10n.scnTxtMedication($0).text }

                return erxTaskRepository.save(
                    erxTasks: erxTasks
                )
                .map { _ in erxTasks }
                .mapError(MainDomain.Error.repositoryError)
                .eraseToAnyPublisher()
            }
            .catchToEffect()
            .map(MainDomain.Action.importReceived)
            .receive(on: schedulers.main)
            .eraseToEffect()
    }

    func checkForTaskDuplicatesInStore(_ sharedTasks: [SharedTask]) -> AnyPublisher<[SharedTask], MainDomain.Error> {
        let findPublishers: [AnyPublisher<SharedTask?, Never>] = sharedTasks.map { sharedTask in
            self.erxTaskRepository.loadLocal(by: sharedTask.id, accessCode: sharedTask.accessCode)
                .first()
                .map { erxTask -> SharedTask? in
                    if erxTask != nil {
                        return nil // by returning nil we sort out previously stored tasks
                    } else {
                        return sharedTask
                    }
                }
                .catch { _ in Just(.none) }
                .eraseToAnyPublisher()
        }

        return Publishers.MergeMany(findPublishers)
            .collect(findPublishers.count)
            .flatMap { optionalTasks -> AnyPublisher<[SharedTask], MainDomain.Error> in
                let tasks = optionalTasks.compactMap { $0 }
                if tasks.isEmpty {
                    return Fail(error: MainDomain.Error.importDuplicate)
                        .eraseToAnyPublisher()
                } else {
                    return Just(tasks)
                        .setFailureType(to: MainDomain.Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .receive(on: schedulers.main)
            .eraseToAnyPublisher()
    }
}

extension MainDomain {
    private static let prescriptionListPullback: Reducer =
        PrescriptionListDomain.reducer.pullback(
            state: \.prescriptionListState,
            action: /Action.prescriptionList(action:)
        ) { mainDomainEnvironment in
            PrescriptionListDomain.Environment(
                router: mainDomainEnvironment.router,
                userSession: mainDomainEnvironment.userSession,
                serviceLocator: mainDomainEnvironment.serviceLocator,
                accessibilityAnnouncementReceiver: mainDomainEnvironment.accessibilityAnnouncementReceiver,
                groupedPrescriptionStore: GroupedPrescriptionInteractor(
                    erxTaskInteractor: mainDomainEnvironment.erxTaskRepository
                ),
                schedulers: mainDomainEnvironment.schedulers,
                fhirDateFormatter: mainDomainEnvironment.fhirDateFormatter,
                loginHandler: DefaultLoginHandler(
                    idpSession: mainDomainEnvironment.userSession.idpSession,
                    signatureProvider: mainDomainEnvironment.signatureProvider
                )
            )
        }

    private static let scannerPullbackReducer: Reducer =
        ScannerDomain.domainReducer._pullback(
            state: (\State.route).appending(path: /Route.scanner),
            action: /MainDomain.Action.scanner(action:)
        ) { globalEnvironment in
            ScannerDomain.Environment(repository: globalEnvironment.erxTaskRepository,
                                      dateFormatter: globalEnvironment.fhirDateFormatter,
                                      scheduler: globalEnvironment.schedulers)
        }

    private static let deviceSecurityPullbackReducer: Reducer =
        DeviceSecurityDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.deviceSecurity),
            action: /MainDomain.Action.deviceSecurity(action:)
        ) {
            DeviceSecurityDomain.Environment(
                deviceSecurityManager: $0.userSessionContainer.userSession.deviceSecurityManager
            )
        }

    private static let extAuthPendingReducer: Reducer =
        ExtAuthPendingDomain.reducer.pullback(
            state: \.extAuthPendingState,
            action: /MainDomain.Action.extAuthPending(action:)
        ) {
            .init(
                idpSession: $0.userSession.idpSession,
                schedulers: $0.schedulers,
                currentProfile: $0.userSession.profile(),
                idTokenValidator: $0.userSession.idTokenValidator(),
                profileDataStore: $0.userSession.profileDataStore,
                extAuthRequestStorage: $0.userSession.extAuthRequestStorage
            )
        }

    static let cardWallPullbackReducer: Reducer =
        CardWallIntroductionDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.cardWall),
            action: /MainDomain.Action.cardWall(action:)
        ) { globalEnvironment in
            CardWallIntroductionDomain.Environment(
                userSession: globalEnvironment.userSession,
                userSessionProvider: globalEnvironment.userSessionProvider,
                sessionProvider: DefaultSessionProvider(
                    userSessionProvider: globalEnvironment.userSessionProvider,
                    userSession: globalEnvironment.userSession
                ),
                schedulers: globalEnvironment.schedulers,
                signatureProvider: globalEnvironment.signatureProvider,
                accessibilityAnnouncementReceiver: globalEnvironment.accessibilityAnnouncementReceiver
            )
        }

    static let prescriptionDetailPullbackReducer: Reducer =
        PrescriptionDetailDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.prescriptionDetail),
            action: /MainDomain.Action.prescriptionDetailAction(action:)
        ) { environment in
            PrescriptionDetailDomain.Environment(
                schedulers: environment.schedulers,
                taskRepository: environment.userSession.erxTaskRepository,
                fhirDateFormatter: environment.fhirDateFormatter,
                userSession: environment.userSession
            )
        }

    static let redeemMethodsPullbackReducer: Reducer =
        RedeemMethodsDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.redeem),
            action: /MainDomain.Action.redeemMethods(action:)
        ) { environment in
            RedeemMethodsDomain.Environment(
                schedulers: environment.schedulers,
                userSession: environment.userSession,
                fhirDateFormatter: environment.fhirDateFormatter,
                signatureProvider: environment.signatureProvider,
                userSessionProvider: environment.userSessionProvider,
                accessibilityAnnouncementReceiver: environment.accessibilityAnnouncementReceiver
            )
        }

    static let horizontalProfileSelectionReducer: Reducer =
        HorizontalProfileSelectionDomain.reducer.pullback(
            state: \.horizontalProfileSelectionState,
            action: /MainDomain.Action.horizontalProfileSelection(action:)
        ) {
            .init(
                schedulers: $0.schedulers,
                userDataStore: $0.userDataStore,
                userProfileService: $0.userProfileService
            )
        }

    private static let addProfilePullbackReducer: Reducer =
        AddProfileDomain.reducer._pullback(
            state: (\State.route).appending(path: /Route.addProfile),
            action: /MainDomain.Action.addProfileAction(action:)
        ) { environment in
            AddProfileDomain.Environment(
                localUserStore: environment.userSession.localUserStore,
                profileStore: environment.userSession.profileDataStore,
                schedulers: environment.schedulers,
                userSession: environment.userSession
            )
        }
}

extension MainDomain {
    enum Dummies {
        static let store = Store(
            initialState: Dummies.state,
            reducer: reducer,
            environment: Dummies.environment
        )
        static let state = State(
            prescriptionListState: PrescriptionListDomain.Dummies.state,
            horizontalProfileSelectionState: HorizontalProfileSelectionDomain.Dummies.state
        )

        static func storeFor(_ state: State) -> Store {
            Store(
                initialState: state,
                reducer: domainReducer,
                environment: Dummies.environment
            )
        }

        static let environment = Environment(
            router: DummyRouter(),
            userSessionContainer: DummyUserSessionContainer(),
            userSession: DummySessionContainer(),
            appSecurityManager: DemoAppSecurityPasswordManager(),
            serviceLocator: ServiceLocator(),
            accessibilityAnnouncementReceiver: { _ in },
            erxTaskRepository: DummySessionContainer().erxTaskRepository,
            schedulers: Schedulers(),
            fhirDateFormatter: globals.fhirDateFormatter,
            userProfileService: DummyUserProfileService(),
            secureDataWiper: DummyProfileSecureDataWiper(),
            signatureProvider: DummySecureEnclaveSignatureProvider(),
            userSessionProvider: DummyUserSessionProvider(),
            userDataStore: DemoUserDefaultsStore(),
            tracker: DummyTracker()
        )
    }
}
