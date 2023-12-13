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

struct MainDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct State: Equatable {
        var isDemoMode = false
        @PresentationState var destination: Destinations.State?

        // Child domain states
        var prescriptionListState: PrescriptionListDomain.State
        var extAuthPendingState = ExtAuthPendingDomain.State()
        var horizontalProfileSelectionState: HorizontalProfileSelectionDomain.State
    }

    enum Action: Equatable {
        /// Presents the `ScannerView`
        case showScannerView
        /// Hides the `ScannerView`
        case loadDeviceSecurityView
        /// Start listening to demo mode changes
        case subscribeToDemoModeChange
        /// Tapping the demo mode banner can also turn the demo mode off
        case turnOffDemoMode
        case externalLogin(URL)
        case importTaskByUrl(URL)
        case showWelcomeDrawer
        case refreshPrescription
        case destination(PresentationAction<Destinations.Action>)
        case setNavigation(tag: Destinations.State.Tag?)
        case response(Response)

        // Child Domain Actions
        case extAuthPending(action: ExtAuthPendingDomain.Action)
        case prescriptionList(action: PrescriptionListDomain.Action)
        case horizontalProfileSelection(action: HorizontalProfileSelectionDomain.Action)

        enum Response: Equatable {
            case loadDeviceSecurityViewReceived(DeviceSecurityDomain.State?)
            case demoModeChangeReceived(Bool)
            case importReceived(Result<[ErxTask], Error>)
        }
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

    @Dependency(\.schedulers) var schedulers
    @Dependency(\.erxTaskRepository) var erxTaskRepository: ErxTaskRepository
    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.changeableUserSessionContainer) var userSessionContainer: UsersSessionContainer
    @Dependency(\.fhirDateFormatter) var fhirDateFormatter: FHIRDateFormatter
    @Dependency(\.userDataStore) var userDataStore: UserDataStore
    @Dependency(\.deviceSecurityManager) var deviceSecurityManager
    @Dependency(\.profileSecureDataWiper) var profileSecureDataWiper: ProfileSecureDataWiper
    @Dependency(\.router) var router: Routing

    var environment: Environment {
        .init(
            router: router,
            userSessionContainer: userSessionContainer,
            userSession: userSession,
            erxTaskRepository: erxTaskRepository,
            schedulers: schedulers,
            fhirDateFormatter: fhirDateFormatter,
            userDataStore: userDataStore,
            deviceSecurityManager: deviceSecurityManager,
            profileSecureDataWiper: profileSecureDataWiper
        )
    }

    struct Environment {
        let router: Routing
        var userSessionContainer: UsersSessionContainer
        var userSession: UserSession
        var erxTaskRepository: ErxTaskRepository
        var schedulers: Schedulers
        var fhirDateFormatter: FHIRDateFormatter
        var userDataStore: UserDataStore
        var deviceSecurityManager: DeviceSecurityManager
        var profileSecureDataWiper: ProfileSecureDataWiper
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \State.prescriptionListState, action: /Action.prescriptionList(action:)) {
            PrescriptionListDomain()
        }
        Scope(state: \State.horizontalProfileSelectionState, action: /Action.horizontalProfileSelection(action:)) {
            HorizontalProfileSelectionDomain()
        }
        Scope(state: \State.extAuthPendingState, action: /Action.extAuthPending(action:)) {
            ExtAuthPendingDomain()
        }

        Reduce(self.core)
            .ifLet(\.$destination, action: /Action.destination) {
                Destinations()
            }
    }
}

extension MainDomain {
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .turnOffDemoMode:
            environment.router.routeTo(.settings(nil))
            return .none
        case let .prescriptionList(action: .profilePictureViewTapped(profile)):
            state.destination = .editProfilePicture(
                EditProfilePictureDomain.State(
                    profileId: profile.id,
                    color: profile.color,
                    picture: profile.image,
                    userImageData: profile.userImageData,
                    isFullScreenPresented: false
                )
            )
            return .none
        case .showScannerView:
            state.destination = .scanner(ScannerDomain.State())
            return .none
        case .loadDeviceSecurityView:
            return .publisher(
                environment.deviceSecurityManager.showSystemSecurityWarning
                    .map { type in
                        switch type {
                        case .none:
                            return nil
                        default:
                            return DeviceSecurityDomain.State(warningType: type)
                        }
                    }
                    .map { .response(.loadDeviceSecurityViewReceived($0)) }
                    .receive(on: environment.schedulers.main)
                    .eraseToAnyPublisher
            )
        case let .response(.loadDeviceSecurityViewReceived(deviceSecurityState)):
            if let deviceSecurityState = deviceSecurityState {
                state.destination = .deviceSecurity(deviceSecurityState)
            }
            return .none
        case .subscribeToDemoModeChange:
            return .publisher(
                environment.userSessionContainer.isDemoMode
                    .map { .response(.demoModeChangeReceived($0)) }
                    .receive(on: environment.schedulers.main.animation())
                    .eraseToAnyPublisher
            )
        case let .response(.demoModeChangeReceived(demoModeValue)):
            state.isDemoMode = demoModeValue
            return .none
        case let .externalLogin(url):
            // [REQ:BSI-eRp-ePA:O.Source_1#7] redirect into correct domain
            return .run { send in
                try await schedulers.main.sleep(for: 5)
                await send(.extAuthPending(action: .externalLogin(url)))
            }
        case let .importTaskByUrl(url):
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  components.path.contains("prescription"),
                  let fragment = components.fragment?.data(using: .utf8),
                  let sharedTasks = try? JSONDecoder().decode([SharedTask].self, from: fragment) else {
                return .none
            }
            return environment.checkForTaskDuplicatesThenSave(sharedTasks)
        case .response(.importReceived(.success)):
            state.destination = .alert(.init(title: L10n.erxTxtPrescriptionAddedAlertTitle))
            return .none
        case let .response(.importReceived(.failure(error))):
            state.destination = .alert(.init(for: error, title: L10n.erxTxtPrescriptionDuplicateAlertTitle))
            return .none
        case .destination(.presented(.deviceSecurity(.delegate(.close)))),
             .setNavigation(tag: .none):
            state.destination = nil
            return .none
        case .setNavigation(tag: .cardWall),
             .destination(.presented(.alert(.cardWall))):
            environment.userSession.idpSession.invalidateAccessToken()
            state.destination = .cardWall(.init(isNFCReady: true, profileId: environment.userSession.profileId))
            return .none
        case let .prescriptionList(action: .response(.errorReceived(error))):
            switch error {
            case .idpError(.biometrics) where error.contains(PrivateKeyContainer.Error.canceledByUser):
                state.destination = .alert(.init(for: error, title: L10n.errSpecificI10808Title, actions: {
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.alertBtnOk)
                    }
                }))
            case let .idpError(.serverError(response))
                where response.code == IDPError.Code.pairingAuthorizationFailed.rawValue:
                state.destination = .alert(AlertStates.devicePairingInvalid())
                return .run { [profileId = environment.userSession.profileId] _ in
                    _ = try await environment.profileSecureDataWiper.wipeSecureData(of: profileId).async()
                }
            case .idpError(.biometrics), .idpError(.serverError):
                state.destination = .alert(AlertStates.loginNecessaryAlert(for: error))
            default:
                state.destination = .alert(
                    .init(for: error, actions: {
                        ButtonState(role: .cancel, action: .dismiss) {
                            .init(L10n.alertBtnOk)
                        }
                    })
                )
            }
            return .none
        case let .prescriptionList(action: .response(.showCardWallReceived(cardWallState))):
            state.destination = .cardWall(cardWallState)
            return .none
        case let .prescriptionList(action: .prescriptionDetailViewTapped(prescription)):
            state.destination = .prescriptionDetail(PrescriptionDetailDomain.State(
                prescription: prescription,
                isArchived: prescription.isArchived
            ))
            return .none
        case let .prescriptionList(action: .redeemButtonTapped(openPrescriptions)):
            state.destination = .redeem(
                RedeemMethodsDomain
                    .State(erxTasks: openPrescriptions.filter(\.isRedeemable).map(\.erxTask))
            )
            return .none
        case .prescriptionList(action: .showArchivedButtonTapped):
            state.destination = .prescriptionArchive(.init())
            return .none
        case .destination(.presented(.cardWall(action: .delegate(.close)))):
            state.destination = nil
            return .send(.prescriptionList(action: .loadRemotePrescriptionsAndSave))
        case .destination(.presented(.redeemMethods(action: .delegate(.close)))),
             .destination(.presented(.prescriptionArchiveAction(action: .delegate(.close)))),
             .destination(.presented(.prescriptionDetailAction(action: .delegate(.close)))):
            state.destination = nil
            return .none
        case let .horizontalProfileSelection(action: .response(.loadReceived(.failure(error)))):
            state.destination = .alert(
                .init(for: error, actions: {
                    ButtonState(role: .cancel, action: .dismiss) {
                        .init(L10n.alertBtnOk)
                    }
                })
            )
            return .none
        case .refreshPrescription:
            return EffectTask.send(.prescriptionList(action: .refresh))
        case .horizontalProfileSelection(action: .showAddProfileView):
            state.destination = .createProfile(CreateProfileDomain.State())
            return .none
        case let .horizontalProfileSelection(action: .showEditProfileNameView(profileId, profileName)):
            state.destination = .editName(EditProfileNameDomain.State(profileName: profileName, profileId: profileId))
            return .none
        case .showWelcomeDrawer:
            if state.destination == nil, !environment.userDataStore.hideWelcomeDrawer {
                state.destination = .welcomeDrawer
                environment.userDataStore.hideWelcomeDrawer = true
            }
            return .none
        case let .destination(.presented(.createProfileAction(action: .delegate(delegateAction)))):
            switch delegateAction {
            case .close:
                state.destination = nil
                return .none
            case let .failure(error):
                state.destination = .alert(
                    .init(for: error, actions: {
                        ButtonState(role: .cancel, action: .dismiss) {
                            .init(L10n.alertBtnOk)
                        }
                    })
                )
                return .none
            }
        case let .destination(.presented(.editProfileNameAction(action: .delegate(delegateAction)))):
            switch delegateAction {
            case .close:
                state.destination = nil
                return .none
            case let .failure(error):
                state.destination = .alert(
                    .init(for: error, actions: {
                        ButtonState(role: .cancel, action: .dismiss) {
                            .init(L10n.alertBtnOk)
                        }
                    })
                )
                return .none
            }
        case let .destination(.presented(.editProfilePictureAction(action: .delegate(delegateAction)))):
            switch delegateAction {
            case .close:
                state.destination = nil
                return .none
            case let .failure(error):
                state.destination = .alert(
                    .init(for: error, actions: {
                        ButtonState(role: .cancel, action: .dismiss) {
                            .init(L10n.alertBtnOk)
                        }
                    })
                )
                return .none
            }
        case .destination(.presented(.cardWall(action: .delegate(.unlockCardClose)))):
            state.destination = nil
            environment.router.routeTo(.settings(.unlockCard))
            return .none
        case .destination,
             .setNavigation,
             .prescriptionList,
             .extAuthPending,
             .horizontalProfileSelection:
            return .none
        }
    }
}

extension MainDomain {
    enum AlertStates {
        static func loginNecessaryAlert(for error: LoginHandlerError) -> ErpAlertState<Destinations.Action.Alert> {
            .init(
                for: error,
                title: L10n.errTitleLoginNecessary
            ) {
                ButtonState(action: .cardWall) {
                    .init(L10n.erxBtnAlertLogin)
                }
            }
        }

        static func devicePairingInvalid() -> ErpAlertState<Destinations.Action.Alert> {
            .init(
                title: L10n.errTitlePairingInvalid,
                actions: {
                    ButtonState(action: .dismiss) {
                        .init(L10n.erxBtnAlertOk)
                    }
                    ButtonState(action: .cardWall) {
                        .init(L10n.erxBtnAlertLogin)
                    }
                },
                message: L10n.errMessagePairingInvalid
            )
        }
    }
}

extension MainDomain.Environment {
    func checkForTaskDuplicatesThenSave(_ sharedTasks: [SharedTask]) -> EffectTask<MainDomain.Action> {
        let authoredOn = fhirDateFormatter.stringWithLongUTCTimeZone(from: Date())
        let erxTaskRepository = self.erxTaskRepository

        return .publisher(
            checkForTaskDuplicatesInStore(sharedTasks)
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
                .catchToPublisher()
                .map { .response(.importReceived($0)) }
                .receive(on: schedulers.main)
                .eraseToAnyPublisher
        )
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
