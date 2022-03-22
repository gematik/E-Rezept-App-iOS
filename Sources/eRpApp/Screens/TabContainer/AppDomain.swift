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

    enum Tab {
        case main
        case pharmacySearch
        case messages
        case settings
    }

    struct State: Equatable {
        var selectedTab: Tab
        var main: MainDomain.State
        var pharmacySearch: PharmacySearchDomain.State
        var messages: MessagesDomain.State
        var settingsState: SettingsDomain.State
        var profileSelection: ProfileSelectionToolbarItemDomain.State
        var debug: DebugDomain.State
        var unreadMessagesCount: Int

        var isDemoMode: Bool
    }

    enum Action: Equatable {
        case main(action: MainDomain.Action)
        case pharmacySearch(action: PharmacySearchDomain.Action)
        case messages(action: MessagesDomain.Action)
        case settings(action: SettingsDomain.Action)
        case debug(action: DebugDomain.Action)
        case profile(action: ProfileSelectionToolbarItemDomain.Action)

        case isDemoModeReceived(Bool)
        case registerDemoModeListener
        case registerUnreadMessagesListener
        case unreadMessagesReceived(Int)
        case selectTab(Tab)
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
    }

    private static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .profile(action: .profileSelection(action: .close)):
            switch state.selectedTab {
            case .main:
                return Effect(value: .main(action: .setNavigation(tag: nil)))
            case .messages:
                return Effect(value: .messages(action: .setNavigation(tag: nil)))
            case .pharmacySearch:
                return Effect(value: .pharmacySearch(action: .setNavigation(tag: nil)))
            default:
                return .none
            }
        case .main,
             .pharmacySearch,
             .messages,
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
        case .registerUnreadMessagesListener:
            return environment.userSessionContainer.userSession.erxTaskRepository
                .countAllUnreadCommunications(for: ErxTask.Communication.Profile.reply)
                .receive(on: environment.schedulers.main.animation())
                .map(AppDomain.Action.unreadMessagesReceived)
                .catch { _ in Effect.none }
                .eraseToEffect()
        case let .unreadMessagesReceived(countUnreadMessages):
            state.unreadMessagesCount = countUnreadMessages
            return .none
        case let .selectTab(tab):
            state.selectedTab = tab
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
                signatureProvider: appEnvironment.signatureProvider,
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
                userSession: appEnvironment.userSession
            )
        }

    private static let messagesPullbackReducer: AppDomain.Reducer =
        MessagesDomain.reducer.pullback(
            state: \.messages,
            action: /AppDomain.Action.messages(action:)
        ) { appEnvironment in
            MessagesDomain.Environment(
                schedulers: appEnvironment.schedulers,
                erxTaskRepository: appEnvironment.userSessionContainer.userSession.erxTaskRepository,
                application: UIApplication.shared
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
                appSecurityManager: appEnvironment.userSession.appSecurityManager,
                router: appEnvironment.router
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
        messagesPullbackReducer,
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
            selectedTab: .main,
            main: MainDomain.Dummies.state,
            pharmacySearch: PharmacySearchDomain.Dummies.state,
            messages: MessagesDomain.Dummies.state,
            settingsState: SettingsDomain.Dummies.state,
            profileSelection: ProfileSelectionToolbarItemDomain.Dummies.state,
            debug: DebugDomain.Dummies.state,
            unreadMessagesCount: 0,
            isDemoMode: false
        )

        static let environment = Environment(
            router: DummyRouter(),
            userSessionContainer: DummyUserSessionContainer(),
            userSession: DemoSessionContainer(),
            userDataStore: DemoUserDefaultsStore(),
            schedulers: Schedulers(),
            fhirDateFormatter: globals.fhirDateFormatter,
            serviceLocator: ServiceLocator(),
            accessibilityAnnouncementReceiver: { _ in },
            tracker: DummyTracker(),
            signatureProvider: DummySecureEnclaveSignatureProvider()
        )
    }
}
