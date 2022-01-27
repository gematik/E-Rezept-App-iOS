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
    @ObservedObject var viewStore: ViewStore<ViewState, MessagesDomain.Action>

    init(store: MessagesDomain.Store) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ViewState.init))
    }

    var body: some View {
        NavigationView {
            VStack {
                if !viewStore.messageDomainStates.isEmpty {
                    ScrollView(.vertical) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEachStore( // swiftlint:disable:this trailing_closure
                                self.store.scope(
                                    state: \.messageDomainStates,
                                    action: MessagesDomain.Action.message
                                ),
                                content: { store in
                                    MessageRowView(store: store)
                                }
                            )
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
        }
        .accentColor(Colors.primary700)
        .navigationViewStyle(StackNavigationViewStyle())
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
        let messageDomainStates: IdentifiedArrayOf<MessageDomain.State>

        init(state: MessagesDomain.State) {
            messageDomainStates = state.messageDomainStates
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessagesView(store: MessagesDomain.Dummies.store)
            MessagesView(store: MessagesDomain.Dummies.storeFor(MessagesDomain.State(messageDomainStates: [])))
        }
    }
}
