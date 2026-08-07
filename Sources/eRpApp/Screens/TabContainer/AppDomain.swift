//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import Combine
import ComposableArchitecture
import eRpKit
import FeatureCommunication
import FeatureHelpers
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
            // sourcery: AnalyticsState = pharmacy
            // sourcery: AnalyticsScreen = pharmacySearch
            case pharmacy
            // sourcery: AnalyticsState = orders
            // sourcery: AnalyticsScreen = orders
            case orders
            // sourcery: AnalyticsState = messages
            // sourcery: AnalyticsScreen = orders
            case messages
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
        @Shared(.isDemoMode) var isDemoMode
        @Shared(.selectedProfileId) var profileId

        var destination: Destinations.State

        var main: MainDomain.State
        var pharmacy: PharmacyContainerDomain.State
        var orders: OrdersDomain.State
        var settings: SettingsDomain.State
        var messages: MessageThreadListDomain.State

        var unreadMessageCount: Int {
            unreadOrderMessageCount + unreadInternalCommunicationCount
        }

        var unreadOrderMessageCount: Int
        var unreadInternalCommunicationCount: Int

        init(
            destination: Destinations.State,
            main: MainDomain.State,
            pharmacy: PharmacyContainerDomain.State,
            orders: OrdersDomain.State,
            messages: MessageThreadListDomain.State,
            settings: SettingsDomain.State,
            unreadOrderMessageCount: Int,
            unreadInternalCommunicationCount: Int
        ) {
            self.destination = destination
            self.main = main
            self.pharmacy = pharmacy
            self.orders = orders
            self.messages = messages
            self.settings = settings
            self.unreadOrderMessageCount = unreadOrderMessageCount
            self.unreadInternalCommunicationCount = unreadInternalCommunicationCount
        }
    }

    enum Action: Equatable {
        case task

        case registerNewMessageListener
        case newOrderMessageReceived(Int)
        case newInternalCommunicationReceived(Int)
        case setNavigation(Destinations.State)

        case main(action: MainDomain.Action)
        case pharmacy(action: PharmacyContainerDomain.Action)
        case orders(action: OrdersDomain.Action)
        case messages(action: MessageThreadListDomain.Action)
        case settings(action: SettingsDomain.Action)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.changeableUserSessionContainer) var userSessionContainer: UsersSessionContainer
    @Dependency(\.erxTaskRepository) var erxTaskRepository
    @Dependency(\.internalCommunicationProtocol) var internalCommunicationProtocol: InternalCommunicationProtocol

    var body: some Reducer<State, Action> {
        Scope(state: \.main, action: \.main) {
            MainDomain()
        }

        Scope(state: \.pharmacy, action: \.pharmacy) {
            PharmacyContainerDomain()
        }

        Scope(state: \.orders, action: \.orders) {
            OrdersDomain()
        }

        Scope(state: \.messages, action: \.messages) {
            MessageThreadListDomain()
        }

        Scope(state: \.settings, action: \.settings) {
            SettingsDomain()
        }

        Reduce(core)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .send(.registerNewMessageListener)
        case .settings(
            action: .destination(
                .presented(.editProfile(.destination(.presented(.alert(.confirmDeleteProfile)))))
            )
        ),
        .settings(action: .destination(.presented(.newProfile(.createAndSaveProfileReceived(.success))))):
            return .concatenate(
                .send(.main(action: .setNavigation(tag: .none))),
                .send(.orders(action: .resetNavigation)),
                .send(.pharmacy(action: .pharmacySearch(.resetNavigation)))
            )
        case .main(action: .horizontalProfileSelection(action: .selectProfile)):
            return .concatenate(
                .send(.orders(action: .resetNavigation)),
                .send(.pharmacy(action: .pharmacySearch(.resetNavigation)))
            )
        case .registerNewMessageListener:
            return .merge(
                .run { [profileId = state.profileId] send in
                    do {
                        for try await count in erxTaskRepository.countAllUnreadCommunicationsAndChargeItems(
                            profileId,
                            .all
                        ) {
                            await send(.newOrderMessageReceived(count), animation: .default)
                        }
                    } catch {
                        await send(.newOrderMessageReceived(67))
                    }
                },
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
                case .pharmacy:
                    state.pharmacy.pharmacySearch.destination = nil
                    return .none
                case .messages:
                    state.messages.destination = nil
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
        case .main, .settings, .pharmacy, .orders, .messages:
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
            pharmacy: PharmacyContainerDomain.State(
                pharmacySearch: PharmacySearchDomain.Dummies.stateStartView
            ),
            orders: OrdersDomain.Dummies.state,
            messages: MessageThreadListDomain.Dummies.state,
            settings: SettingsDomain.Dummies.state,
            unreadOrderMessageCount: 0,
            unreadInternalCommunicationCount: 0
        )
    }
}

extension SharedReaderKey
    where Self == AppStorageKey<Bool>.Default {
    /// A key to determine whether the app should show the feature eu redeeming of prescriptions.
    /// As soon as this feature goes live, this key should be removed.
    public static var communicationsV3Feature: Self {
        Self[.appStorage("communications_v3_feature"), default: false]
    }
}
