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
import IDP

enum MainDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    enum Route: Equatable {
        case selectProfile

        enum Tag: Int {
            case selectProfile
        }

        var tag: Tag {
            switch self {
            case .selectProfile:
                return .selectProfile
            }
        }
    }

    struct State: Equatable {
        var scannerState: ScannerDomain.State?
        var deviceSecurityState: DeviceSecurityDomain.State?
        var prescriptionListState: GroupedPrescriptionListDomain.State
        var extAuthPendingState = ExtAuthPendingDomain.State()
        var isDemoMode = false

        var route: Route?
    }

    enum Token: CaseIterable, Hashable {
        case demoMode
    }

    enum Action: Equatable {
        /// Presents the `ScannerView`
        case showScannerView
        /// Hides the `ScannerView`
        case dismissScannerView
        case loadDeviceSecurityView
        case loadDeviceSecurityViewReceived(DeviceSecurityDomain.State?)
        case dismissDeviceSecurityView
        /// Child view actions for the `GroupedPrescriptionListDomain`
        case prescriptionList(action: GroupedPrescriptionListDomain.Action)
        /// Child view actions for the `ScannerDomain`
        case scanner(action: ScannerDomain.Action)
        case deviceSecurity(action: DeviceSecurityDomain.Action)
        /// Start listening to demo mode changes
        case subscribeToDemoModeChange
        case unsubscribeFromDemoModeChange
        case demoModeChangeReceived(Bool)
        /// Tapping the demo mode banner can also turn the demo mode off
        case turnOffDemoMode

        case externalLogin(URL)
        case extAuthPending(action: ExtAuthPendingDomain.Action)

        case setNavigation(tag: Route.Tag?)
    }

    enum Error: Swift.Error, Equatable {
        case localStoreError(LocalStoreError)
        case userSessionError(UserSessionError)
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

        var signatureProvider: SecureEnclaveSignatureProvider

        let tracker: Tracker
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .showScannerView:
            state.scannerState = ScannerDomain.State()
            return .none
        case .dismissScannerView,
             .scanner(action: .close):
            state.scannerState = nil
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
            state.deviceSecurityState = deviceSecurityState
            return .none
        case .prescriptionList,
             .scanner,
             .extAuthPending:
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
            return .cancel(id: Token.demoMode)
        case .deviceSecurity(.close),
             .dismissDeviceSecurityView:
            state.deviceSecurityState = nil
            return Effect.cancel(token: DeviceSecurityDomain.Token.self)
        case .deviceSecurity:
            return .none
        case let .externalLogin(url):
            return Effect(value: .extAuthPending(action: .externalLogin(url)))
                .delay(for: 5, scheduler: environment.schedulers.main)
                .eraseToEffect()
        case .setNavigation(tag: .selectProfile):
            state.route = .selectProfile
            return .none
        case .setNavigation(tag: .none):
            state.route = nil
            return ProfileSelectionDomain.cleanup()
        case .setNavigation:
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        groupedPrescriptionListPullback,
        scannerPullbackReducer,
        deviceSecurityPullbackReducer,
        extAuthPendingReducer,
        domainReducer
    )

    private static let groupedPrescriptionListPullback: Reducer =
        GroupedPrescriptionListDomain.reducer.pullback(
            state: \.prescriptionListState,
            action: /Action.prescriptionList(action:)
        ) { mainDomainEnvironment in
            GroupedPrescriptionListDomain.Environment(
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
                ),
                signatureProvider: mainDomainEnvironment.signatureProvider
            )
        }

    private static let scannerPullbackReducer: Reducer =
        ScannerDomain.domainReducer.optional().pullback(
            state: \.scannerState,
            action: /MainDomain.Action.scanner(action:)
        ) { globalEnvironment in
            ScannerDomain.Environment(repository: globalEnvironment.erxTaskRepository,
                                      dateFormatter: globalEnvironment.fhirDateFormatter,
                                      scheduler: globalEnvironment.schedulers)
        }

    private static let deviceSecurityPullbackReducer: Reducer =
        DeviceSecurityDomain.reducer.optional().pullback(
            state: \.deviceSecurityState,
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
}

extension MainDomain {
    enum Dummies {
        static let store = Store(
            initialState: Dummies.state,
            reducer: reducer,
            environment: Dummies.environment
        )

        static let state = State(
            prescriptionListState: GroupedPrescriptionListDomain.Dummies.state
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
            userSession: DemoSessionContainer(),
            appSecurityManager: DemoAppSecurityPasswordManager(),
            serviceLocator: ServiceLocator(),
            accessibilityAnnouncementReceiver: { _ in },
            erxTaskRepository: DemoSessionContainer().erxTaskRepository,
            schedulers: Schedulers(),
            fhirDateFormatter: globals.fhirDateFormatter,
            userProfileService: DummyUserProfileService(),
            signatureProvider: DummySecureEnclaveSignatureProvider(),
            tracker: DummyTracker()
        )
    }
}
