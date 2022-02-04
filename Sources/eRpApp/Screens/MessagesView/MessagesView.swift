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

import ComposableArchitecture
import eRpKit
import SwiftUI

struct MessagesView: View {
    let store: MessagesDomain.Store
    @ObservedObject var viewStore: ViewStore<MessagesDomain.State, MessagesDomain.Action>

    init(store: MessagesDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        NavigationView {
            VStack {
                if !viewStore.state.communications.isEmpty {
                    ScrollView(.vertical) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(viewStore.communications) { communication in
                                Button(action: { viewStore.send(.didSelect(communication.id)) }, label: {
                                    MessageRowView(communication: communication)
                                })
                            }
                        }
                        .padding(.top)
                        .padding(.bottom)
                    }
                } else {
                    NoMessagesView()
                        .padding()
                }
            }
            .navigationBarTitle(L10n.msgsTxtTitle, displayMode: .automatic)
            .accessibility(identifier: A11y.messages.list.msgsTxtTitle)
            .onAppear { viewStore.send(.subscribeToCommunicationChanges) }
            .onDisappear { viewStore.send(.removeSubscription) }
            .alert(
                self.store
                    .scope(state: (\MessagesDomain.State.route).appending(path: /MessagesDomain.Route.alert)
                        .extract(from:)),
                dismiss: .setNavigation(tag: .none)
            )
            .sheet(isPresented: Binding<Bool>(
                get: { viewStore.route?.tag == .pickupCode },
                set: { show in
                    if !show { viewStore.send(.setNavigation(tag: .none)) }
                }
            )) {
                IfLetStore(pickupCodeStore, then: PickupCodeView.init(store:))
            }
        }
        .accentColor(Colors.primary700)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    var pickupCodeStore: Store<PickupCodeDomain.State?, PickupCodeDomain.Action> {
        store.scope(
            state: (\MessagesDomain.State.route).appending(path: /MessagesDomain.Route.pickupCode).extract(from:),
            action: MessagesDomain.Action.pickupCode(action:)
        )
    }

    struct NoMessagesView: View {
        var body: some View {
            VStack(spacing: 8) {
                Text(L10n.msgsTxtEmptyListTitle)
                    .font(.headline)
                Text(L10n.msgsTxtEmptyListMessage)
                    .font(.subheadline)
                    .foregroundColor(Colors.systemLabelSecondary)
            }
            .accessibility(identifier: A11y.messages.list.msgsTxtEmptyList)
        }
    }
}

extension MessagesView {
    struct ViewState: Equatable {
        let communications: IdentifiedArrayOf<ErxTask.Communication>
        let route: MessagesDomain.Route?

        init(state: MessagesDomain.State) {
            communications = state.communications
            route = state.route
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessagesView(store: MessagesDomain.Dummies.store)
            MessagesView(store: MessagesDomain.Dummies.storeFor(MessagesDomain.State(communications: [])))
        }
    }
}
