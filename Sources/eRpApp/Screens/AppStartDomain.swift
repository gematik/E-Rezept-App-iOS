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

enum AppStartDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.Reducer<State, Action, Environment>

    enum State: Equatable {
        case loading
        case onboarding(OnboardingDomain.State)
        case app(AppDomain.State)

        init() {
            self = .loading
        }
    }

    enum Action: Equatable {
        case app(action: AppDomain.Action)
        case onboarding(action: OnboardingDomain.Action)
        case refreshOnboardingState
        case refreshOnboardingStateReceived(OnboardingDomain.Composition)
    }

    struct Environment {
        let appVersion: AppVersion
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
        let appSecurityManager: AppSecurityManager
        let authenticationChallengeProvider: AuthenticationChallengeProvider
    }

    private static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .onboarding(action: .dismissOnboarding):
            state = .app(
                AppDomain.State(
                    selectedTab: .main,
                    main: MainDomain.State(
                        prescriptionListState: GroupedPrescriptionListDomain.State(),
                        debug: DebugDomain.State(trackingOptOut: environment.tracker.optOut)
                    ),
                    messages: MessagesDomain.State(messageDomainStates: []),
                    unreadMessagesCount: 0,
                    isDemoMode: false
                )
            )
            return .none
        case .app,
             .onboarding:
            return .none
        case .refreshOnboardingState:
            return environment.userDataStore.hideOnboarding
                .zip(environment.userDataStore.onboardingVersion)
                .first()
                .receive(on: environment.schedulers.main)
                .map(OnboardingDomain.Composition.init)
                .map(AppStartDomain.Action.refreshOnboardingStateReceived)
                .eraseToEffect()

        case let .refreshOnboardingStateReceived(composition):
            guard composition.isEmpty else {
                state = .onboarding(OnboardingDomain.State(composition: composition))
                return .none
            }
            state = .app(
                AppDomain.State(
                    selectedTab: .main,
                    main: MainDomain.State(
                        prescriptionListState: GroupedPrescriptionListDomain.State(),
                        debug: DebugDomain.State(trackingOptOut: environment.tracker.optOut)
                    ),
                    messages: MessagesDomain.State(messageDomainStates: []),
                    unreadMessagesCount: 0,
                    isDemoMode: false
                )
            )
            return .none
        }
    }

    private static let onboardingPullbackReducer: AppStartDomain.Reducer =
        OnboardingDomain.reducer
            .pullback(
                state: /AppStartDomain.State.onboarding,
                action: /AppStartDomain.Action.onboarding(action:)
            ) {
                OnboardingDomain.Environment(
                    appVersion: $0.appVersion,
                    localUserStore: $0.userDataStore,
                    schedulers: $0.schedulers,
                    appSecurityManager: $0.appSecurityManager,
                    authenticationChallengeProvider: $0.authenticationChallengeProvider
                )
            }

    private static let appPullbackReducer: AppStartDomain.Reducer =
        AppDomain.reducer
            .pullback(
                state: /AppStartDomain.State.app,
                action: /AppStartDomain.Action.app(action:)
            ) { appStartEnvironment in
                AppDomain.Environment(
                    router: appStartEnvironment.router,
                    userSessionContainer: appStartEnvironment.userSessionContainer,
                    userSession: appStartEnvironment.userSession,
                    schedulers: appStartEnvironment.schedulers,
                    fhirDateFormatter: appStartEnvironment.fhirDateFormatter,
                    serviceLocator: appStartEnvironment.serviceLocator,
                    accessibilityAnnouncementReceiver: appStartEnvironment.accessibilityAnnouncementReceiver,
                    tracker: appStartEnvironment.tracker,
                    signatureProvider: appStartEnvironment.signatureProvider
                )
            }

    static let reducer = Reducer.combine(
        onboardingPullbackReducer,
        appPullbackReducer,
        domainReducer
    )

    static let router: (Endpoint) -> Effect<Action, Never> = { route in
        switch route {
        case .settings:
            return Effect(value: .app(action: .main(action: .showSettingsView)))
        case .scanner:
            return Effect(value: .app(action: .main(action: .showScannerView)))
        case .messages:
            return Effect(value: .app(action: .selectTab(.messages)))
        case let .universalLink(url):
            return Effect(value: .app(action: .main(action: .externalLogin(url))))
        }
    }
}
