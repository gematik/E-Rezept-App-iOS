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

struct AppDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    struct Subdomains: ReducerProtocol {
        struct State: Equatable {
            var main: MainDomain.State
            var pharmacySearch: PharmacySearchDomain.State
            var orders: OrdersDomain.State
            var settingsState: SettingsDomain.State
            var profileSelection: ProfileSelectionToolbarItemDomain.State
        }

        enum Action: Equatable {
            case main(action: MainDomain.Action)
            case pharmacySearch(action: PharmacySearchDomain.Action)
            case orders(action: OrdersDomain.Action)
            case settings(action: SettingsDomain.Action)
            case profile(action: ProfileSelectionToolbarItemDomain.Action)
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
                state: \.settingsState,
                action: /Action.settings(action:)
            ) {
                SettingsDomain()
            }

            Scope(
                state: \.profileSelection,
                action: /Action.profile(action:)
            ) {
                ProfileSelectionToolbarItemDomain()
            }
        }
    }

    // sourcery: AnalyticsIgnoreGeneration
    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsState = subdomains.main
            case main
            // sourcery: AnalyticsState = subdomains.pharmacySearch
            case pharmacySearch
            // sourcery: AnalyticsState = subdomains.orders
            case orders
            // sourcery: AnalyticsState = subdomains.settingsState
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
    }

    enum Action: Equatable {
        case isDemoModeReceived(Bool)
        case registerDemoModeListener
        case registerNewOrderMessageListener
        case newOrderMessageReceived(Int)
        case setNavigation(Destinations.State)

        case subdomains(Subdomains.Action)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.changeableUserSessionContainer) var userSessionContainer: UsersSessionContainer
    @Dependency(\.erxTaskRepository) var erxTaskRepository

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.subdomains, action: /Action.subdomains) {
            Subdomains()
        }

        Reduce(self.core)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .subdomains(.profile(action: .profileSelection(action: .close))):
            switch state.destination {
            case .main:
                return Effect(value: .subdomains(.main(action: .setNavigation(tag: nil))))
            case .orders:
                return Effect(value: .subdomains(.orders(action: .setNavigation(tag: nil))))
            case .pharmacySearch:
                return Effect(value: .subdomains(.pharmacySearch(action: .setNavigation(tag: nil))))
            default:
                return .none
            }
        case .subdomains(.settings(action: .profiles(action: .destination(.editProfileAction(.confirmDeleteProfile))))),
             .subdomains(
                 .settings(
                     action: .profiles(
                         action: .destination(.newProfileAction(action: .response(.saveReceived(.success))))
                     )
                 )
             ):
            return .concatenate(
                .init(value: .subdomains(.main(action: .setNavigation(tag: nil)))),
                .init(value: .subdomains(.orders(action: .setNavigation(tag: nil)))),
                .init(value: .subdomains(.pharmacySearch(action: .setNavigation(tag: nil))))
            )
        case .subdomains(.profile(action: .profileSelection(action: .selectProfile))):
            return .concatenate(
                .init(value: .subdomains(.main(action: .setNavigation(tag: nil)))),
                .init(value: .subdomains(.orders(action: .setNavigation(tag: nil)))),
                .init(value: .subdomains(.pharmacySearch(action: .setNavigation(tag: nil))))
            )
        case .subdomains(.main(action: .horizontalProfileSelection(action: .selectProfile))):
            return .concatenate(
                .init(value: .subdomains(.orders(action: .setNavigation(tag: nil)))),
                .init(value: .subdomains(.pharmacySearch(action: .setNavigation(tag: nil))))
            )
        case .subdomains:
            return .none
        case let .isDemoModeReceived(isDemoMode):
            state.isDemoMode = isDemoMode
            state.subdomains.settingsState.isDemoMode = isDemoMode
            return .none
        case .registerDemoModeListener:
            return userSessionContainer.isDemoMode
                .map(AppDomain.Action.isDemoModeReceived)
                .eraseToEffect()
        case .registerNewOrderMessageListener:
            return erxTaskRepository
                .countAllUnreadCommunications(for: ErxTask.Communication.Profile.all)
                .receive(on: schedulers.main.animation())
                .map(AppDomain.Action.newOrderMessageReceived)
                .catch { _ in Effect.none }
                .eraseToEffect()
        case let .newOrderMessageReceived(unreadOrderMessageCount):
            state.unreadOrderMessageCount = unreadOrderMessageCount
            return .none
        case let .setNavigation(destination):
            state.destination = destination
            return .none
        }
    }
}

extension AppDomain {
    enum Dummies {
        static let store = Store(
            initialState: state,
            reducer: AppDomain()
        )

        static let state = State(
            destination: .main,
            subdomains: .init(
                main: MainDomain.Dummies.state,
                pharmacySearch: PharmacySearchDomain.Dummies.stateStartView,
                orders: OrdersDomain.Dummies.state,
                settingsState: SettingsDomain.Dummies.state,
                profileSelection: ProfileSelectionToolbarItemDomain.Dummies.state
            ),
            unreadOrderMessageCount: 0,
            isDemoMode: false
        )
    }
}
