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
import IDP
import SwiftUI

struct AppStartDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

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

    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.userDataStore) var userDataStore: UserDataStore
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager

    var body: some ReducerProtocol<State, Action> {
        Scope(
            state: /State.onboarding,
            action: /Action.onboarding(action:)
        ) {
            OnboardingDomain()
        }

        Scope(
            state: /State.app,
            action: /Action.app(action:)
        ) {
            AppDomain()
        }

        Reduce(self.core)
    }

    // swiftlint:disable:next function_body_length
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onboarding(action: .dismissOnboarding):
            state = .app(
                AppDomain.State(
                    destination: .main,
                    subdomains: .init(
                        main: .init(
                            prescriptionListState: .init(),
                            horizontalProfileSelectionState: .init()
                        ),
                        pharmacySearch: PharmacySearchDomain.State(erxTasks: []),
                        orders: OrdersDomain.State(orders: []),
                        settingsState: .init(
                            isDemoMode: userSession.isDemoMode,
                            appSecurityState: .init(
                                availableSecurityOptions: appSecurityManager.availableSecurityOptions
                                    .options,
                                selectedSecurityOption: nil,
                                errorToDisplay: nil
                            )
                        ),
                        profileSelection: .init()
                    ),
                    unreadOrderMessageCount: 0,
                    isDemoMode: false
                )
            )
            return .none
        case .app,
             .onboarding:
            return .none
        case .refreshOnboardingState:
            return userDataStore.hideOnboarding
                .zip(userDataStore.onboardingVersion)
                .first()
                .receive(on: schedulers.main)
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
                    destination: .main,
                    subdomains: .init(
                        main: .init(prescriptionListState: .init(), horizontalProfileSelectionState: .init()),
                        pharmacySearch: PharmacySearchDomain.State(erxTasks: []),
                        orders: OrdersDomain.State(orders: []),
                        settingsState: .init(
                            isDemoMode: userSession.isDemoMode,
                            appSecurityState: .init(
                                availableSecurityOptions: appSecurityManager.availableSecurityOptions
                                    .options,
                                selectedSecurityOption: nil,
                                errorToDisplay: nil
                            )
                        ),
                        profileSelection: .init()
                    ),
                    unreadOrderMessageCount: 0,
                    isDemoMode: false
                )
            )
            return .none
        }
    }

    static let router: (Endpoint) -> EffectTask<Action> = { route in
        switch route {
        case .settings:
            return Effect.concatenate(
                Effect(value: .app(action: .subdomains(.settings(action: .popToRootView)))),
                Effect(value: .app(action: .setNavigation(.settings)))
            )
        case .scanner:
            return Effect(value: .app(action: .subdomains(.main(action: .showScannerView))))
        case .orders:
            return Effect(value: .app(action: .setNavigation(.orders)))
        case let .mainScreen(endpoint):
            switch endpoint {
            case .login:
                return Effect.merge(
                    Effect(value: .app(action: .setNavigation(.main))),
                    Effect(value: .app(action: .subdomains(.main(action: .prescriptionList(action: .refresh)))))
                )
            default:
                return Effect(value: .app(action: .setNavigation(.main)))
            }
        case let .universalLink(url):
            switch url.path {
            case "/extauth":
                return Effect(value: .app(action: .subdomains(.main(action: .externalLogin(url)))))
            case "/prescription":
                return Effect(value: .app(action: .subdomains(.main(action: .importTaskByUrl(url)))))
            default:
                return .none
            }
        }
    }
}
