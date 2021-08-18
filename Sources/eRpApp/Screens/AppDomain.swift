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
import SwiftUI

enum AppDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    enum Tab {
        case main
        case messages
    }

    struct State: Equatable {
        var selectedTab: Tab
        var onboarding: OnboardingDomain.State?
        var appAuthentication: AppAuthenticationDomain.State?
        var main: MainDomain.State
        var messages: MessagesDomain.State
        var unreadMessagesCount: Int

        var isOnboardingVisible: Bool {
            onboarding?.onboardingVisible ?? false
        }

        var isDemoMode: Bool
    }

    enum Action: Equatable {
        case main(action: MainDomain.Action)
        case messages(action: MessagesDomain.Action)
        case appAuthentication(action: AppAuthenticationDomain.Action)
        case onboarding(action: OnboardingDomain.Action)
        case loadOnboarding
        case loadOnboardingResponse(OnboardingDomain.State)
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
        var schedulers: Schedulers
        var fhirDateFormatter: FHIRDateFormatter
        var serviceLocator: ServiceLocator
        let accessibilityAnnouncementReceiver: (String) -> Void

        let tracker: Tracker
        let signatureProvider: SecureEnclaveSignatureProvider
    }

    private static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .appAuthentication,
             .onboarding,
             .main,
             .messages:
            return .none
        case let .loadOnboardingResponse(onboardingState):
            state.onboarding = onboardingState
            return .none
        case .loadOnboarding:
            return environment.userSessionContainer.userSession.localUserStore.hideOnboarding
                .map { Action.loadOnboardingResponse(OnboardingDomain.State(onboardingVisible: !$0)) }
                .receive(on: environment.schedulers.main)
                .eraseToEffect()
        case let .isDemoModeReceived(isDemoMode):
            state.isDemoMode = isDemoMode
            state.main.settingsState?.isDemoMode = isDemoMode
            return .none
        case .registerDemoModeListener:
            return environment.userSessionContainer.isDemoMode
                .map(AppDomain.Action.isDemoModeReceived)
                .eraseToEffect()
        case .registerUnreadMessagesListener:
            return environment.userSession.erxTaskRepository.countAllUnreadCommunications(for: .reply)
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

    private static let onboardingPullbackReducer: AppDomain.Reducer =
        OnboardingDomain.reducer
            .optional()
            .pullback(
                state: \.onboarding,
                action: /AppDomain.Action.onboarding(action:)
            ) {
                OnboardingDomain.Environment(
                    userSession: $0.userSessionContainer.userSession,
                    schedulers: $0.schedulers
                )
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
                serviceLocator: appEnvironment.serviceLocator,
                accessibilityAnnouncementReceiver: appEnvironment.accessibilityAnnouncementReceiver,
                erxTaskRepository: appEnvironment.userSessionContainer.userSession.erxTaskRepository,
                schedulers: appEnvironment.schedulers,
                fhirDateFormatter: appEnvironment.fhirDateFormatter,
                signatureProvider: appEnvironment.signatureProvider,
                tracker: appEnvironment.tracker
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

    static let reducer = Reducer.combine(
        onboardingPullbackReducer,
        mainPullbackReducer,
        messagesPullbackReducer,
        domainReducer
    )
    .recordActionsForHints()

    static let router: (Endpoint) -> Effect<Action, Never> = { route in
        switch route {
        case .settings:
            return Effect(value: AppDomain.Action.main(action: .showSettingsView))
        case .scanner:
            return Effect(value: AppDomain.Action.main(action: .showScannerView))
        case .messages:
            return Effect(value: AppDomain.Action.selectTab(.messages))
        }
    }
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
            onboarding: OnboardingDomain.Dummies.state,
            appAuthentication: AppAuthenticationDomain.Dummies.state,
            main: MainDomain.Dummies.state,
            messages: MessagesDomain.Dummies.state,
            unreadMessagesCount: 0,
            isDemoMode: false
        )

        static let environment = Environment(
            router: DummyRouter(),
            userSessionContainer: DummyUserSessionContainer(),
            userSession: AppContainer.shared.userSessionSubject,
            schedulers: Schedulers(),
            fhirDateFormatter: AppContainer.shared.fhirDateFormatter,
            serviceLocator: ServiceLocator(),
            accessibilityAnnouncementReceiver: { _ in },
            tracker: DummyTracker(),
            signatureProvider: DummySecureEnclaveSignatureProvider()
        )
    }
}
