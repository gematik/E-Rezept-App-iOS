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

struct AppDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct Subdomains: ReducerProtocol {
        struct State: Equatable {
            var main: MainDomain.State
            var pharmacySearch: PharmacySearchDomain.State
            var orders: OrdersDomain.State
            var settings: SettingsDomain.State
        }

        enum Action: Equatable {
            case main(action: MainDomain.Action)
            case pharmacySearch(action: PharmacySearchDomain.Action)
            case orders(action: OrdersDomain.Action)
            case settings(action: SettingsDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: \.main,
                action: /Action.main(action:)
            ) {
                MainDomain()
            }

            Scope(
                state: \.pharmacySearch,
                action: /Action.pharmacySearch(action:)
            ) {
                PharmacySearchDomain(referenceDateForOpenHours: nil)
            }

            Scope(
                state: \.orders,
                action: /Action.orders(action:)
            ) {
                OrdersDomain()
            }

            Scope(
                state: \.settings,
                action: /Action.settings(action:)
            ) {
                SettingsDomain()
            }
        }
    }

    // sourcery: AnalyticsIgnoreGeneration
    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsState = subdomains.main
            // sourcery: AnalyticsScreen = main
            case main
            // sourcery: AnalyticsState = subdomains.pharmacySearch
            // sourcery: AnalyticsScreen = pharmacySearch
            case pharmacySearch
            // sourcery: AnalyticsState = subdomains.orders
            // sourcery: AnalyticsScreen = orders
            case orders
            // sourcery: AnalyticsState = subdomains.settings
            // sourcery: AnalyticsScreen = settings
            case settings
        }

        enum Action: Equatable {}

        var body: some ReducerProtocol<State, Action> {
            EmptyReducer()
        }
    }

    struct State: Equatable {
        var destination: Destinations.State

        var subdomains: Subdomains.State

        var unreadOrderMessageCount: Int
        var isDemoMode: Bool

        init(
            destination: Destinations.State,
            subdomains: Subdomains.State,
            unreadOrderMessageCount: Int,
            isDemoMode: Bool
        ) {
            self.destination = destination
            self.subdomains = subdomains
            self.unreadOrderMessageCount = unreadOrderMessageCount
            self.isDemoMode = isDemoMode
        }
    }

    enum Action: Equatable {
        case task

        case isDemoModeReceived(Bool)
        case registerDemoModeListener
        case registerNewOrderMessageListener
        case newOrderMessageReceived(Int)
        case setNavigation(Destinations.State)

        case subdomains(Subdomains.Action)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.changeableUserSessionContainer) var userSessionContainer: UsersSessionContainer
    @Dependency(\.entireErxTaskRepository) var entireErxTaskRepository

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.subdomains, action: /Action.subdomains) {
            Subdomains()
        }

        Reduce(self.core)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .task:
            return .merge(
                .send(.registerDemoModeListener),
                .send(.registerNewOrderMessageListener)
            )
        case .subdomains(
            .settings(
                action: .destination(
                    .presented(.editProfileAction(.destination(.presented(.alert(.confirmDeleteProfile)))))
                )
            )
        ),
        .subdomains(
            .settings(action: .destination(.presented(.newProfileAction(.response(.saveReceived(.success))))))
        ):
            return .concatenate(
                .send(.subdomains(.main(action: .setNavigation(tag: nil)))),
                .send(.subdomains(.orders(action: .setNavigation(tag: nil)))),
                .send(.subdomains(.pharmacySearch(action: .setNavigation(tag: nil))))
            )
        case .subdomains(.main(action: .horizontalProfileSelection(action: .selectProfile))):
            return .concatenate(
                .send(.subdomains(.orders(action: .setNavigation(tag: nil)))),
                .send(.subdomains(.pharmacySearch(action: .setNavigation(tag: nil))))
            )
        case .subdomains:
            return .none
        case let .isDemoModeReceived(isDemoMode):
            state.isDemoMode = isDemoMode
            state.subdomains.settings.isDemoMode = isDemoMode
            return .none
        case .registerDemoModeListener:
            return .publisher(
                userSessionContainer.isDemoMode
                    .map(AppDomain.Action.isDemoModeReceived)
                    .eraseToAnyPublisher
            )
        case .registerNewOrderMessageListener:
            return .publisher(
                entireErxTaskRepository
                    .countAllUnreadCommunicationsAndChargeItems(for: .all)
                    .receive(on: schedulers.main.animation())
                    .map(AppDomain.Action.newOrderMessageReceived)
                    .catch { _ in Empty() }
                    .eraseToAnyPublisher
            )
        case let .newOrderMessageReceived(unreadOrderMessageCount):
            state.unreadOrderMessageCount = unreadOrderMessageCount
            return .none
        case let .setNavigation(destination):
            if state.destination == destination {
                // When user taps on the active TabItem (current destination == next destination),
                // we present the "root" view of the corresponding TabView's content
                switch destination {
                case .main:
                    state.subdomains.main.destination = nil
                    return .none
                case .pharmacySearch:
                    state.subdomains.pharmacySearch.destination = nil
                    return .none
                case .orders:
                    state.subdomains.orders.destination = nil
                    return .none
                case .settings:
                    state.subdomains.settings.destination = nil
                    return .none
                }
            } else {
                state.destination = destination
                return .none
            }
        }
    }
}

extension AppDomain {
    enum Dummies {
        static let store = Store(initialState: state) {
            AppDomain()
        }

        static let state = State(
            destination: .main,
            subdomains: .init(
                main: MainDomain.Dummies.state,
                pharmacySearch: PharmacySearchDomain.Dummies.stateStartView,
                orders: OrdersDomain.Dummies.state,
                settings: SettingsDomain.Dummies.state
            ),
            unreadOrderMessageCount: 0,
            isDemoMode: false
        )
    }
}
