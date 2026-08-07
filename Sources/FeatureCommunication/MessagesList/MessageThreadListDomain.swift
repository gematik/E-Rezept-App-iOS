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

import ComposableArchitecture
import eRpKit
import eRpLocalStorage
import FeatureHelpers
import Foundation
import IdentifiedCollections
import Profiles

/// The domain of the messages list screen, which shows all messages related to orders and internal communications.
@Reducer
public struct MessageThreadListDomain {
    /// The type of the store of the messages list domain.
    public init() {}

    /// The possible destinations of the messages list screen, which can be either the order detail screen or an alert.
    @Reducer
    public enum Destination {
        /// The order detail screen, which shows the details of a specific order and its related messages.
        case orderDetail(MessageThreadDomain)

        /// An alert screen, which shows an error message when loading the messages or orders fails.
        @ReducerCaseEphemeral
        // sourcery: AnalyticsScreen = alert
        case alert(ErpAlertState<Never>)
    }

    /// The state of the messages list screen, which contains the list of messages and the loading state.
    @ObservableState
    public struct State: Equatable {
        /// The list of messages related to orders and internal communications, which is shared across the app and can
        /// be updated by other domains.
        public init() {
            _communicationMessage = Shared<IdentifiedArrayOf<CommunicationMessage>>(value: [])
        }

        init(communicationMessage: Shared<IdentifiedArrayOf<CommunicationMessage>>) {
            _communicationMessage = communicationMessage
        }

        var isLoading = false
        var hideCompleted = false
        var profileName: String?
        @Shared var communicationMessage: IdentifiedArrayOf<CommunicationMessage>
        /// The destination of the messages list screen, which can be either the order detail screen or an alert.
        @Presents public var destination: Destination.State?
        @Shared(.selectedProfileId) var profileId

        var filteredMessages: IdentifiedArrayOf<CommunicationMessage> {
            if hideCompleted {
                return communicationMessage.filter(\.hasUnreadMessages)
            }
            return communicationMessage
        }
    }

    /// The actions of the messages list screen, which can be either a task to load the messages, or a response from the
    /// repositories, or a navigation action to the destination.
    public enum Action: Equatable {
        case task
        case loadOrders
        case loadMessages
        case loadEuOrders
        case loadProfile
        case didSelect(String)
        case toggleHideCompleted

        case destination(PresentationAction<Destination.Action>)

        case response(Response)

        /// The response from the repositories, which can be either the orders, the internal communications, or the EU
        /// orders.
        public enum Response: Equatable {
            case ordersReceived(Result<IdentifiedArrayOf<Order>, OrdersRepositoryError>)
            case euOrdersReceived(Result<IdentifiedArrayOf<EuOrder>, OrdersRepositoryError>)
            case internalCommunicationReceived(Result<IdentifiedArrayOf<InternalCommunication>,
                InternalCommunicationError>)
            case profileReceived(Profile?)
        }
    }

    @Dependency(\.communicationsRepository) var communicationsRepository
    @Dependency(\.internalCommunicationClient) var internalCommunicationClient
    @Dependency(\.profilesStore) var profilesStore

    /// The reducer of the messages list screen
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                state.isLoading = true
                return .merge(
                    .send(.loadOrders),
                    .send(.loadMessages),
                    .send(.loadEuOrders),
                    .send(.loadProfile)
                )
            case let .didSelect(messageId):
                guard state.communicationMessage[id: messageId] != nil else {
                    return .none
                }
                state.destination = .orderDetail(MessageThreadDomain.State())
                return .none
            case .toggleHideCompleted:
                state.hideCompleted.toggle()
                return .none
            case .loadProfile:
                return .run { [profileId = state.profileId] send in
                    let profile = try await profilesStore.fetchProfile(identifier: profileId).async()
                    await send(.response(.profileReceived(profile)))
                } catch: { _, _ in }
            case .loadOrders:
                return .run { send in
                    for try await orders in communicationsRepository.loadAllOrders() {
                        await send(.response(.ordersReceived(.success(orders))))
                    }
                }
                catch: { error, send in
                    await send(.response(.ordersReceived(.failure(error.asOrdersError()))))
                }
            case .loadMessages:
                return .run { send in
                    do {
                        let messages = try await internalCommunicationClient.load()
                        await send(.response(.internalCommunicationReceived(.success(messages))))
                    } catch {
                        await send(.response(.internalCommunicationReceived(.failure(error
                                .asInternalCommunicationError()))))
                    }
                }
            case .loadEuOrders:
                return .run { [profileId = state.profileId] send in
                    for try await euOrders in communicationsRepository.loadEuOrders(profileId: profileId) {
                        await send(.response(.euOrdersReceived(.success(euOrders))))
                    }
                }
                catch: { error, send in
                    await send(.response(.euOrdersReceived(.failure(error.asOrdersError()))))
                }
            case let .response(.euOrdersReceived(result)):
                switch result {
                case let .success(orders):
                    for order in orders {
                        _ = state.$communicationMessage.withLock { messages in
                            messages.updateOrAppend(CommunicationMessage.euOrder(order))
                        }
                    }
                    let sortedMessages: [CommunicationMessage] = state.communicationMessage.elements.sorted {
                        $0.lastUpdated > $1.lastUpdated
                    }
                    state.$communicationMessage.withLock { $0 = IdentifiedArray(uniqueElements: sortedMessages) }
                case let .failure(error):
                    state.destination = .alert(.init(for: error))
                    return .none
                }
                state.isLoading = false
                return .none
            case let .response(.ordersReceived(result)):
                switch result {
                case let .success(orders):
                    for order in orders {
                        _ = state.$communicationMessage.withLock { messages in
                            messages.updateOrAppend(CommunicationMessage.order(order))
                        }
                    }
                    let sortedMessages: [CommunicationMessage] = state.communicationMessage.elements.sorted {
                        $0.lastUpdated > $1.lastUpdated
                    }
                    state.$communicationMessage.withLock { $0 = IdentifiedArray(uniqueElements: sortedMessages) }
                case let .failure(error):
                    state.destination = .alert(.init(for: error))
                    return .none
                }
                state.isLoading = false
                return .none
            case let .response(.internalCommunicationReceived(result)):
                switch result {
                case let .success(messages):
                    for message in messages {
                        _ = state.$communicationMessage.withLock { messages in
                            messages.updateOrAppend(CommunicationMessage.internalCommunication(message))
                        }
                    }
                    let sortedMessages: [CommunicationMessage] = state.communicationMessage.elements.sorted {
                        $0.lastUpdated > $1.lastUpdated
                    }
                    state.$communicationMessage.withLock { $0 = IdentifiedArray(uniqueElements: sortedMessages) }
                case let .failure(error):
                    state.destination = .alert(.init(for: error))
                }
                state.isLoading = false
                return .none
            case let .response(.profileReceived(profile)):
                state.profileName = profile?.name
                return .none
            default: return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension MessageThreadListDomain {
    /// The dummies for the messages list domain, which can be used for previews and tests.
    public enum Dummies {
        /// The state of the messages list screen, which contains a list of messages related to orders and internal
        /// communications.
        public static let state: State = {
            var state = State(communicationMessage: Shared(value: [
                CommunicationMessage.order(Order.Dummies.orderCommunications1),
                CommunicationMessage.internalCommunication(InternalCommunication(
                    messages: [
                        InternalCommunication.Message(
                            id: "welcome-1",
                            timestamp: Date(),
                            text: "Willkommen bei der E-Rezept App!",
                            version: "0.0.0",
                            isRead: false
                        ),
                    ]
                )),
                CommunicationMessage.order(Order.Dummies.orderCommunications2),
            ]))
            state.profileName = "Ada Muster"
            return state
        }()

        /// The store of the messages list domain, which is initialized with the dummy state and the reducer.
        public static let store = StoreOf<MessageThreadListDomain>(
            initialState: state
        ) {
            MessageThreadListDomain()
        }

        /// A helper function to create a store of the messages list domain with a given state, which can be used for
        /// previews and tests.
        public static func storeFor(_ state: State) -> StoreOf<MessageThreadListDomain> {
            Store(
                initialState: state
            ) {
                MessageThreadListDomain()
            }
        }
    }
}

extension MessageThreadListDomain.Destination.State: Equatable {}
extension MessageThreadListDomain.Destination.Action: Equatable {}
