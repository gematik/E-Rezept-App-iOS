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

enum MainDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    struct State: Equatable {
        var scannerState: ScannerDomain.State?
        var settingsState: SettingsDomain.State?
        var prescriptionListState: GroupedPrescriptionListDomain.State
        var debug: DebugDomain.State
        var isDemoMode = false
    }

    enum Token: CaseIterable, Hashable {
        case demoMode
    }

    enum Action: Equatable {
        /// Presents the `ScannerView`
        case showScannerView
        /// Hides the `ScannerView`
        case dismissScannerView
        /// Presents the `SettingsView`
        case showSettingsView
        /// Hides the `SettingsView`
        case dismissSettingsView
        /// Child view actions for the `SettingsDomain`
        case settings(action: SettingsDomain.Action)
        /// Child view actions for the `GroupedPrescriptionListDomain`
        case prescriptionList(action: GroupedPrescriptionListDomain.Action)
        /// Child view actions for the `ScannerDomain`
        case scanner(action: ScannerDomain.Action)
        /// Debug actions
        case debug(action: DebugDomain.Action)
        /// Start listening to demo mode changes
        case subscribeToDemoModeChange
        case unsubscribeFromDemoModeChange
        case demoModeChangeReceived(Bool)
        /// Tapping the demo mode banner can also turn the demo mode off
        case turnOffDemoMode
    }

    struct Environment {
        let router: Routing
        var userSessionContainer: UsersSessionContainer
        var userSession: UserSession
        var serviceLocator: ServiceLocator
        let accessibilityAnnouncementReceiver: (String) -> Void
        var erxTaskRepository: ErxTaskRepositoryAccess
        var schedulers: Schedulers
        var fhirDateFormatter: FHIRDateFormatter

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
        case .dismissSettingsView,
             .settings(action: .close):
            state.settingsState = nil
            return .none
        case .showSettingsView,
             .turnOffDemoMode:
            state.settingsState = SettingsDomain.State(
                isDemoMode: environment.userSession.isDemoMode,
                debug: state.debug
            )
            return .none
        case .prescriptionList,
             .settings,
             .scanner:
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
        case .debug:
            return .none
        }
    }

    static let reducer: Reducer = .combine(
        settingsPullbackReducer,
        groupedPrescriptionListPullback,
        scannerPullbackReducer,
        debugPullbackReducer,
        domainReducer
    )

    private static let settingsPullbackReducer: Reducer =
        SettingsDomain.reducer.optional().pullback(
            state: \.settingsState,
            action: /MainDomain.Action.settings(action:)
        ) { appEnvironment in
            SettingsDomain.Environment(
                changeableUserSessionContainer: appEnvironment.userSessionContainer,
                schedulers: appEnvironment.schedulers,
                tracker: appEnvironment.tracker,
                signatureProvider: appEnvironment.signatureProvider
            )
        }

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

    private static let debugPullbackReducer: Reducer =
        DebugDomain.reducer.pullback(
            state: \.debug,
            action: /MainDomain.Action.debug(action:)
        ) { appEnvironment in
            DebugDomain.Environment(
                schedulers: appEnvironment.schedulers,
                userSession: appEnvironment.userSession,
                tracker: appEnvironment.tracker,
                signatureProvider: appEnvironment.signatureProvider
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
            prescriptionListState: GroupedPrescriptionListDomain.Dummies.state,
            debug: DebugDomain.Dummies.state
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
            userSessionContainer: AppContainer.shared.userSessionContainer,
            userSession: AppContainer.shared.userSessionSubject,
            serviceLocator: ServiceLocator(),
            accessibilityAnnouncementReceiver: { _ in },
            erxTaskRepository: AppContainer.shared.userSessionSubject.erxTaskRepository,
            schedulers: AppContainer.shared.schedulers,
            fhirDateFormatter: AppContainer.shared.fhirDateFormatter,
            signatureProvider: DummySecureEnclaveSignatureProvider(),
            tracker: DummyTracker()
        )
    }
}
