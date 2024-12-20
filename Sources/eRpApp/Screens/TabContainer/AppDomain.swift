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

@Reducer
struct AppDomain {
    typealias Store = StoreOf<Self>

    // sourcery: AnalyticsIgnoreGeneration
    struct Destinations: Reducer {
        enum State: Int, Equatable {
            // sourcery: AnalyticsState = main
            // sourcery: AnalyticsScreen = main
            case main
            // sourcery: AnalyticsState = pharmacySearch
            // sourcery: AnalyticsScreen = pharmacySearch
            case pharmacySearch
            // sourcery: AnalyticsState = orders
            // sourcery: AnalyticsScreen = orders
            case orders
            // sourcery: AnalyticsState = settings
            // sourcery: AnalyticsScreen = settings
            case settings
        }

        enum Action: Equatable {}

        var body: some ReducerOf<Self> {
            EmptyReducer()
        }
    }

    @ObservableState
    struct State: Equatable {
        var destination: Destinations.State

        var main: MainDomain.State
        var pharmacySearch: PharmacySearchDomain.State
        var orders: OrdersDomain.State
        var settings: SettingsDomain.State

        var unreadMessageCount: Int {
            unreadOrderMessageCount + unreadInternalCommunicationCount
        }

        var unreadOrderMessageCount: Int
        var unreadInternalCommunicationCount: Int
        var isDemoMode: Bool

        init(
            destination: Destinations.State,
            main: MainDomain.State,
            pharmacySearch: PharmacySearchDomain.State,
            orders: OrdersDomain.State,
            settings: SettingsDomain.State,
            unreadOrderMessageCount: Int,
            unreadInternalCommunicationCount: Int,
            isDemoMode: Bool
        ) {
            self.destination = destination
            self.main = main
            self.pharmacySearch = pharmacySearch
            self.orders = orders
            self.settings = settings
            self.unreadOrderMessageCount = unreadOrderMessageCount
            self.unreadInternalCommunicationCount = unreadInternalCommunicationCount
            self.isDemoMode = isDemoMode
        }
    }

    enum Action: Equatable {
        case task

        case isDemoModeReceived(Bool)
        case registerDemoModeListener
        case registerNewMessageListener
        case newOrderMessageReceived(Int)
        case newInternalCommunicationReceived(Int)
        case setNavigation(Destinations.State)

        case main(action: MainDomain.Action)
        case pharmacySearch(action: PharmacySearchDomain.Action)
        case orders(action: OrdersDomain.Action)
        case settings(action: SettingsDomain.Action)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.changeableUserSessionContainer) var userSessionContainer: UsersSessionContainer
    @Dependency(\.entireErxTaskRepository) var entireErxTaskRepository
    @Dependency(\.internalCommunicationProtocol) var internalCommunicationProtocol: InternalCommunicationProtocol

    var body: some Reducer<State, Action> {
        Scope(state: \.main, action: \.main) {
            MainDomain()
        }

        Scope(state: \.pharmacySearch, action: \.pharmacySearch) {
            PharmacySearchDomain()
        }

        Scope(state: \.orders, action: \.orders) {
            OrdersDomain()
        }

        Scope(state: \.settings, action: \.settings) {
            SettingsDomain()
        }

        Reduce(self.core)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .merge(
                .send(.registerDemoModeListener),
                .send(.registerNewMessageListener)
            )
        case .settings(
            action: .destination(
                .presented(.editProfile(.destination(.presented(.alert(.confirmDeleteProfile)))))
            )
        ),
        .settings(action: .destination(.presented(.newProfile(.response(.saveReceived(.success)))))):
            return .concatenate(
                .send(.main(action: .setNavigation(tag: .none))),
                .send(.orders(action: .resetNavigation)),
                .send(.pharmacySearch(action: .resetNavigation))
            )
        case .main(action: .horizontalProfileSelection(action: .selectProfile)):
            return .concatenate(
                .send(.orders(action: .resetNavigation)),
                .send(.pharmacySearch(action: .resetNavigation))
            )
        case let .isDemoModeReceived(isDemoMode):
            state.isDemoMode = isDemoMode
            state.settings.isDemoMode = isDemoMode
            return .none
        case .registerDemoModeListener:
            return .publisher(
                userSessionContainer.isDemoMode
                    .map(AppDomain.Action.isDemoModeReceived)
                    .eraseToAnyPublisher
            )
        case .registerNewMessageListener:
            return .merge(
                .publisher(
                    entireErxTaskRepository
                        .countAllUnreadCommunicationsAndChargeItems(for: .all)
                        .receive(on: schedulers.main.animation())
                        .map(AppDomain.Action.newOrderMessageReceived)
                        .catch { _ in Empty() }
                        .eraseToAnyPublisher
                ),
                .run { send in
                    do {
                        for try await counter in internalCommunicationProtocol.loadUnreadInternalCommunicationsCount() {
                            await send(.newInternalCommunicationReceived(counter))
                        }
                    } catch {
                        await send(.newInternalCommunicationReceived(0))
                    }
                }
            )
        case let .newOrderMessageReceived(unreadOrderMessageCount):
            state.unreadOrderMessageCount = unreadOrderMessageCount
            return .none
        case let .newInternalCommunicationReceived(unreadInternalCommunicationCount):
            state.unreadInternalCommunicationCount = unreadInternalCommunicationCount
            return .none
        case let .setNavigation(destination):
            if state.destination == destination {
                // When user taps on the active TabItem (current destination == next destination),
                // we present the "root" view of the corresponding TabView's content
                switch destination {
                case .main:
                    state.main.destination = nil
                    return .none
                case .pharmacySearch:
                    state.pharmacySearch.destination = nil
                    return .none
                case .orders:
                    state.orders.destination = nil
                    return .none
                case .settings:
                    state.settings.destination = nil
                    return .none
                }
            } else {
                state.destination = destination
                return .none
            }
        case .main, .settings, .pharmacySearch, .orders:
            return .none
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
            main: MainDomain.Dummies.state,
            pharmacySearch: PharmacySearchDomain.Dummies.stateStartView,
            orders: OrdersDomain.Dummies.state,
            settings: SettingsDomain.Dummies.state,
            unreadOrderMessageCount: 0,
            unreadInternalCommunicationCount: 0,
            isDemoMode: false
        )
    }
}
