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
import IDP
import SwiftUI

struct AppStartDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct Destination: ReducerProtocol {
        enum State: Equatable {
            case loading
            case onboarding(OnboardingDomain.State)
            case app(AppDomain.State)
        }

        enum Action: Equatable {
            case app(AppDomain.Action)
            case onboarding(OnboardingDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.onboarding,
                action: /Action.onboarding
            ) {
                OnboardingDomain()
            }

            Scope(
                state: /State.app,
                action: /Action.app
            ) {
                AppDomain()
            }
        }
    }

    struct State: Equatable {
        var destination: Destination.State = .loading
    }

    enum Action: Equatable {
        case destination(Destination.Action)

        case refreshOnboardingState
        case refreshOnboardingStateReceived(OnboardingDomain.Composition)
    }

    @Dependency(\.userSession) var userSession: UserSession
    @Dependency(\.userDataStore) var userDataStore: UserDataStore
    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager

    var body: some ReducerProtocol<State, Action> {
        Scope(
            state: \.destination,
            action: /Action.destination
        ) {
            Destination()
        }

        Reduce(self.core)
    }

    // swiftlint:disable:next function_body_length
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .destination(.onboarding(.dismissOnboarding)):
            state.destination = .app(
                AppDomain.State(
                    destination: .main,
                    subdomains: .init(
                        main: .init(
                            prescriptionListState: .init(),
                            horizontalProfileSelectionState: .init()
                        ),
                        pharmacySearch: PharmacySearchDomain.State(erxTasks: []),
                        orders: OrdersDomain.State(orders: []),
                        settings: .init(
                            isDemoMode: userSession.isDemoMode
                        )
                    ),
                    unreadOrderMessageCount: 0,
                    isDemoMode: false
                )
            )
            return .none
        case .destination:
            return .none
        case .refreshOnboardingState:
            return .publisher(
                userDataStore.onboardingVersion
                    .first()
                    .receive(on: schedulers.main)
                    .map(OnboardingDomain.Composition.init)
                    .map(AppStartDomain.Action.refreshOnboardingStateReceived)
                    .eraseToAnyPublisher
            )

        case let .refreshOnboardingStateReceived(composition):
            guard composition.isEmpty else {
                state.destination = .onboarding(OnboardingDomain.State(composition: composition))
                return .none
            }
            state.destination = .app(
                AppDomain.State(
                    destination: .main,
                    subdomains: .init(
                        main: .init(prescriptionListState: .init(), horizontalProfileSelectionState: .init()),
                        pharmacySearch: PharmacySearchDomain.State(erxTasks: []),
                        orders: OrdersDomain.State(orders: []),
                        settings: .init(
                            isDemoMode: userSession.isDemoMode
                        )
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
        case let .settings(endpoint):
            switch endpoint {
            case .unlockCard:
                return .run { send in
                    // reset destination of settings tab
                    await send(.destination(.app(.subdomains(.settings(action: .popToRootView)))))
                    // wait for running effects to finish
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    // switch to the settings tab
                    await send(.destination(.app(.setNavigation(.settings))))
                    // set actual destination in settings tab
                    await send(
                        .destination(
                            .app(.subdomains(.settings(action: .setNavigation(tag: .healthCardPasswordUnlockCard))))
                        )
                    )
                }
            case let .editProfile(editProfile):
                switch editProfile {
                case let .chargeItemListFor(profileId):
                    return .run { send in
                        // reset destination of settings tab
                        await send(.destination(.app(.subdomains(.settings(action: .popToRootView)))))
                        // wait for running effects to finish
                        @Dependency(\.schedulers) var schedulers
                        try await schedulers.main.sleep(for: 0.5)
                        // switch to settings tab
                        await send(.destination(.app(.setNavigation(.settings))))
                        // set actual destination in settings tab
                        await send(
                            .destination(
                                .app(.subdomains(.settings(action: .showChargeItemListFor(profileId: profileId))))
                            )
                        )
                    }
                }
            case .medicationSchedule:
                return .run { send in
                    // reset destination of settings tab
                    await send(.destination(.app(.subdomains(.settings(action: .popToRootView)))))
                    // wait for running effects to finish
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    // switch to settings tab
                    await send(.destination(.app(.setNavigation(.settings))))
                    // set actual destination in settings tab
                    await send(
                        .destination(.app(.subdomains(.settings(action: .setNavigation(tag: .medicationReminderList)))))
                    )
                }
            default:
                return .run { send in
                    await send(.destination(.app(.subdomains(.settings(action: .popToRootView)))))
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    await send(.destination(.app(.setNavigation(.settings))))
                }
            }

        case .scanner:
            return .run { send in
                // reset destination of settings tab
                await send(.destination(.app(.subdomains(.main(action: .setNavigation(tag: nil))))))
                // wait for possible running effects to finish
                @Dependency(\.schedulers) var schedulers
                try await schedulers.main.sleep(for: 0.5)
                // switch to main tab
                await send(.destination(.app(.setNavigation(.main))))
                // set actual destination in main tab
                await send(.destination(.app(.subdomains(.main(action: .showScannerView)))))
            }
        case .orders:
            return .run { send in
                // reset destination of orders tab
                await send(.destination(.app(.subdomains(.orders(action: .setNavigation(tag: nil))))))
                // wait for possible running effects to finish
                @Dependency(\.schedulers) var schedulers
                try await schedulers.main.sleep(for: 0.5)
                // switch to orders tab
                await send(.destination(.app(.setNavigation(.orders))))
            }
        case let .mainScreen(endpoint):
            switch endpoint {
            case let .medicationReminder(scheduleEntries):
                return .run { send in
                    // reset destination of main tab
                    await send(.destination(.app(.subdomains(.main(action: .setNavigation(tag: nil))))))
                    // wait for possible running effects to finish
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    // switch to main tab
                    await send(.destination(.app(.setNavigation(.main))))
                    // set actual destination in main tab
                    await send(.destination(.app(.subdomains(.main(action: .showMedicationReminder(scheduleEntries))))))
                }
            case .login:
                return .run { send in
                    // reset destination of main tab
                    await send(.destination(.app(.subdomains(.main(action: .setNavigation(tag: nil))))))
                    // wait for possible running effects to finish
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    // switch to main tab
                    await send(.destination(.app(.setNavigation(.main))))
                    // set actual destination in main tab
                    await send(.destination(.app(.subdomains(.main(action: .prescriptionList(action: .refresh))))))
                }
            default:
                return .run { send in
                    // reset destination of main tab
                    await send(.destination(.app(.subdomains(.main(action: .setNavigation(tag: nil))))))
                    // wait for possible running effects to finish
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    // switch to main tab
                    await send(.destination(.app(.setNavigation(.main))))
                }
            }
        // [REQ:BSI-eRp-ePA:O.Source_1#6] External application calls via Universal Linking
        case let .universalLink(url):
            switch url.path {
            case "/extauth":
                return .run { send in
                    // reset destination of main tab
                    await send(.destination(.app(.subdomains(.main(action: .setNavigation(tag: nil))))))
                    // wait for possible running effects to finish
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    // switch to main tab
                    await send(.destination(.app(.setNavigation(.main))))
                    // set actual destination in main tab
                    await send(.destination(.app(.subdomains(.main(action: .externalLogin(url))))))
                }
            case "/pharmacies/index.html",
                 "/pharmacies":
                return .run { send in
                    // reset destination of pharmacy tab
                    await send(.destination(.app(.subdomains(.pharmacySearch(action: .setNavigation(tag: nil))))))
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    await send(.destination(.app(.setNavigation(.pharmacySearch))))
                    // set actual destination in pharmacy tab
                    await send(.destination(.app(.subdomains(.pharmacySearch(action: .universalLink(url))))))
                }
            case "/prescription":
                return .run { send in
                    // reset destination of main tab
                    await send(.destination(.app(.subdomains(.main(action: .setNavigation(tag: nil))))))
                    // wait for possible running effects to finish
                    @Dependency(\.schedulers) var schedulers
                    try await schedulers.main.sleep(for: 0.5)
                    // switch to main tab
                    await send(.destination(.app(.setNavigation(.main))))
                    // set actual destination in main tab
                    await send(.destination(.app(.subdomains(.main(action: .importTaskByUrl(url))))))
                }
            default:
                return .none
            }
        }
    }
}
