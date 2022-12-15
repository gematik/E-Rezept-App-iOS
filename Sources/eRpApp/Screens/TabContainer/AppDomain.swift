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
import SwiftUI

enum AppDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    enum Route {
        case main
        case pharmacySearch
        case orders
        case settings
    }

    struct State: Equatable {
        var route: Route
        var main: MainDomain.State
        var pharmacySearch: PharmacySearchDomain.State
        var orders: OrdersDomain.State
        var settingsState: SettingsDomain.State
        var profileSelection: ProfileSelectionToolbarItemDomain.State
        var debug: DebugDomain.State
        var unreadOrderMessageCount: Int

        var isDemoMode: Bool
    }

    enum Action: Equatable {
        case main(action: MainDomain.Action)
        case pharmacySearch(action: PharmacySearchDomain.Action)
        case orders(action: OrdersDomain.Action)
        case settings(action: SettingsDomain.Action)
        case debug(action: DebugDomain.Action)
        case profile(action: ProfileSelectionToolbarItemDomain.Action)

        case isDemoModeReceived(Bool)
        case registerDemoModeListener
        case registerNewOrderMessageListener
        case newOrderMessageReceived(Int)
        case selectTab(Route)
    }

    struct Environment {
        let router: Routing
        var userSessionContainer: UsersSessionContainer
        var userSession: UserSession
        let userDataStore: UserDataStore
        var schedulers: Schedulers
        var fhirDateFormatter: FHIRDateFormatter
        var serviceLocator: ServiceLocator
        let accessibilityAnnouncementReceiver: (String) -> Void

        let tracker: Tracker
        let signatureProvider: SecureEnclaveSignatureProvider
        let userSessionProvider: UserSessionProvider
    }

    private static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .profile(action: .profileSelection(action: .close)):
            switch state.route {
            case .main:
                return Effect(value: .main(action: .setNavigation(tag: nil)))
            case .orders:
                return Effect(value: .orders(action: .setNavigation(tag: nil)))
            case .pharmacySearch:
                return Effect(value: .pharmacySearch(action: .setNavigation(tag: nil)))
            default:
                return .none
            }
        case .settings(action: .profiles(action: .profile(action: .confirmDeleteProfile))),
             .settings(action: .profiles(action: .newProfile(action: .saveReceived(.success)))):
            return .concatenate(
                .init(value: .main(action: .setNavigation(tag: nil))),
                .init(value: .orders(action: .setNavigation(tag: nil))),
                .init(value: .pharmacySearch(action: .setNavigation(tag: nil)))
            )
        case .profile(action: .profileSelection(action: .selectProfile)):
            return .concatenate(
                .init(value: .main(action: .setNavigation(tag: nil))),
                .init(value: .orders(action: .setNavigation(tag: nil))),
                .init(value: .pharmacySearch(action: .setNavigation(tag: nil)))
            )
        case .main,
             .pharmacySearch,
             .orders,
             .settings,
             .debug,
             .profile:
            return .none
        case let .isDemoModeReceived(isDemoMode):
            state.isDemoMode = isDemoMode
            state.settingsState.isDemoMode = isDemoMode
            return .none
        case .registerDemoModeListener:
            return environment.userSessionContainer.isDemoMode
                .map(AppDomain.Action.isDemoModeReceived)
                .eraseToEffect()
        case .registerNewOrderMessageListener:
            return environment.userSessionContainer.userSession.erxTaskRepository
                .countAllUnreadCommunications(for: ErxTask.Communication.Profile.all)
                .receive(on: environment.schedulers.main.animation())
                .map(AppDomain.Action.newOrderMessageReceived)
                .catch { _ in Effect.none }
                .eraseToEffect()
        case let .newOrderMessageReceived(unreadOrderMessageCount):
            state.unreadOrderMessageCount = unreadOrderMessageCount
            return .none
        case let .selectTab(tab):
            state.route = tab
            return .none
        }
    }

    private static let mainPullbackReducer: AppDomain.Reducer =
        MainDomain.reducer.pullback(
            state: \.main,
            action: /AppDomain.Action.main(action:)
        ) { appEnvironment in
            MainDomain.Environment(
                router: appEnvironment.router,
                userSessionContainer: appEnvironment.userSessionContainer,
                userSession: appEnvironment.userSessionContainer.userSession,
                appSecurityManager: appEnvironment.userSessionContainer.userSession.appSecurityManager,
                serviceLocator: appEnvironment.serviceLocator,
                accessibilityAnnouncementReceiver: appEnvironment.accessibilityAnnouncementReceiver,
                erxTaskRepository: appEnvironment.userSessionContainer.userSession.erxTaskRepository,
                schedulers: appEnvironment.schedulers,
                fhirDateFormatter: appEnvironment.fhirDateFormatter,
                userProfileService: DefaultUserProfileService(
                    profileDataStore: appEnvironment.userSessionContainer.userSession.profileDataStore,
                    profileOnlineChecker: DefaultProfileOnlineChecker(),
                    userSession: appEnvironment.userSessionContainer.userSession
                ),
                secureDataWiper: DefaultProfileSecureDataWiper(userSessionProvider: appEnvironment.userSessionProvider),
                signatureProvider: appEnvironment.signatureProvider,
                userSessionProvider: appEnvironment.userSessionProvider,
                userDataStore: appEnvironment.userDataStore,
                tracker: appEnvironment.tracker
            )
        }

    private static let pharmacySearchPullbackReducer: AppDomain.Reducer =
        PharmacySearchDomain.reducer.pullback(
            state: \.pharmacySearch,
            action: /AppDomain.Action.pharmacySearch(action:)
        ) { appEnvironment in
            PharmacySearchDomain.Environment(
                schedulers: appEnvironment.schedulers,
                pharmacyRepository: appEnvironment.userSession.pharmacyRepository,
                locationManager: .live,
                fhirDateFormatter: appEnvironment.fhirDateFormatter,
                openHoursCalculator: PharmacyOpenHoursCalculator(),
                referenceDateForOpenHours: nil,
                userSession: appEnvironment.userSession,
                openURL: UIApplication.shared.open(_:options:completionHandler:),
                signatureProvider: appEnvironment.signatureProvider,
                accessibilityAnnouncementReceiver: appEnvironment.accessibilityAnnouncementReceiver,
                userSessionProvider: appEnvironment.userSessionProvider
            )
        }

    private static let ordersPullbackReducer: AppDomain.Reducer =
        OrdersDomain.reducer.pullback(
            state: \.orders,
            action: /AppDomain.Action.orders(action:)
        ) { appEnvironment in
            OrdersDomain.Environment(
                schedulers: appEnvironment.schedulers,
                userSession: appEnvironment.userSessionContainer.userSession,
                fhirDateFormatter: appEnvironment.fhirDateFormatter,
                erxTaskRepository: appEnvironment.userSessionContainer.userSession.erxTaskRepository,
                pharmacyRepository: appEnvironment.userSession.pharmacyRepository
            )
        }

    private static let settingsPullbackReducer: Reducer =
        SettingsDomain.reducer.pullback(
            state: \.settingsState,
            action: /AppDomain.Action.settings(action:)
        ) { appEnvironment in
            .init(
                changeableUserSessionContainer: appEnvironment.userSessionContainer,
                schedulers: appEnvironment.schedulers,
                tracker: appEnvironment.tracker,
                signatureProvider: appEnvironment.signatureProvider,
                nfcHealthCardPasswordController: appEnvironment.userSession.nfcHealthCardPasswordController,
                appSecurityManager: appEnvironment.userSession.appSecurityManager,
                router: appEnvironment.router,
                userSessionProvider: appEnvironment.userSessionProvider,
                accessibilityAnnouncementReceiver: appEnvironment.accessibilityAnnouncementReceiver
            )
        }

    private static let debugPullbackReducer: Reducer =
        DebugDomain.reducer.pullback(
            state: \.debug,
            action: /AppDomain.Action.debug(action:)
        ) { appEnvironment in
            DebugDomain.Environment(
                schedulers: appEnvironment.schedulers,
                userSession: appEnvironment.userSession,
                localUserStore: appEnvironment.userDataStore,
                tracker: appEnvironment.tracker,
                signatureProvider: appEnvironment.signatureProvider,
                serviceLocatorDebugAccess: ServiceLocatorDebugAccess(serviceLocator: appEnvironment.serviceLocator)
            )
        }

    private static let profileSelectionReducer: Reducer =
        ProfileSelectionToolbarItemDomain.reducer.pullback(
            state: \.profileSelection,
            action: /Action.profile(action:)
        ) {
            .init(
                schedulers: $0.schedulers,
                userDataStore: $0.userSessionContainer.userSession.localUserStore,
                userProfileService: DefaultUserProfileService(
                    profileDataStore: $0.userSessionContainer.userSession.profileDataStore,
                    profileOnlineChecker: DefaultProfileOnlineChecker(),
                    userSession: $0.userSessionContainer.userSession
                ),
                router: $0.router
            )
        }

    static let reducer = Reducer.combine(
        mainPullbackReducer,
        pharmacySearchPullbackReducer,
        ordersPullbackReducer,
        settingsPullbackReducer,
        debugPullbackReducer,
        profileSelectionReducer,
        domainReducer
    )
    .recordActionsForHints()
}

extension AppDomain {
    enum Dummies {
        static let store = Store(
            initialState: state,
            reducer: domainReducer,
            environment: environment
        )

        static let state = State(
            route: .main,
            main: MainDomain.Dummies.state,
            pharmacySearch: PharmacySearchDomain.Dummies.state,
            orders: OrdersDomain.Dummies.state,
            settingsState: SettingsDomain.Dummies.state,
            profileSelection: ProfileSelectionToolbarItemDomain.Dummies.state,
            debug: DebugDomain.Dummies.state,
            unreadOrderMessageCount: 0,
            isDemoMode: false
        )

        static let environment = Environment(
            router: DummyRouter(),
            userSessionContainer: DummyUserSessionContainer(),
            userSession: DummySessionContainer(),
            userDataStore: DemoUserDefaultsStore(),
            schedulers: Schedulers(),
            fhirDateFormatter: globals.fhirDateFormatter,
            serviceLocator: ServiceLocator(),
            accessibilityAnnouncementReceiver: { _ in },
            tracker: DummyTracker(),
            signatureProvider: DummySecureEnclaveSignatureProvider(),
            userSessionProvider: DummyUserSessionProvider()
        )
    }
}
