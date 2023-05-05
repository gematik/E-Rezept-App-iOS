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

import ComposableArchitecture
import IDP
import SwiftUI

struct ExtAuthPendingView: View {
    let store: ExtAuthPendingDomain.Store

    @ObservedObject
    private var viewStore: ViewStore<ExtAuthPendingDomain.State, ExtAuthPendingDomain.Action>

    init(store: ExtAuthPendingDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var background: Color {
        switch viewStore.state {
        case .extAuthFailed:
            return Colors.red300
        default:
            return Color(.secondarySystemBackground)
        }
    }

    @ViewBuilder
    func text() -> some View {
        let name = viewStore.state.entry?.name ?? ""

        switch viewStore.state {
        case .pendingExtAuth:
            Text(L10n.mainTxtPendingextauthPending(name))
        case .extAuthReceived:
            Text(L10n.mainTxtPendingextauthResolving(name))
        case .extAuthSuccessful:
            Text(L10n.mainTxtPendingextauthSuccessful(name))
        case .empty, .extAuthFailed:
            EmptyView()
        }
    }

    @ViewBuilder
    func icon() -> some View {
        switch viewStore.state {
        case .pendingExtAuth,
             .extAuthReceived:
            ProgressView()
                .progressViewStyle(.circular)
        case .extAuthSuccessful:
            Image(systemName: SFSymbolName.checkmark)
                .font(.subheadline)
                .foregroundColor(Colors.secondary600)
        default:
            EmptyView()
        }
    }

    var showToast: Bool {
        switch viewStore.state {
        case .empty,
             .extAuthFailed:
            return false
        case .pendingExtAuth,
             .extAuthReceived,
             .extAuthSuccessful:
            return true
        }
    }

    var body: some View {
        VStack {
            Spacer()
                .alert(
                    store.scope(state: /ExtAuthPendingDomain.State.extAuthFailed),
                    dismiss: .nothing
                )

            if showToast {
                HStack(spacing: 16) {
                    icon()

                    text()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: {
                        viewStore.send(.cancelAllPendingRequests, animation: .easeInOut)
                    }, label: {
                        Image(systemName: SFSymbolName.crossIconPlain)
                    })
                }
                .transition(.move(edge: .bottom))
                .foregroundColor(Color(.secondaryLabel))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(background)
                .cornerRadius(16)
                .padding()
            }
        }
        .onAppear {
            viewStore.send(.registerListener)
        }
        .onDisappear {
            viewStore.send(.unregisterListener)
        }
    }
}

struct ExtAuthPendingView_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            ExtAuthPendingView(store: ExtAuthPendingDomain.Dummies.store(
                for: .empty
            ))
            ExtAuthPendingView(store: ExtAuthPendingDomain.Dummies.store(
                for: .pendingExtAuth(KKAppDirectory
                    .Entry(name: "Gematik KK", identifier: "identifier"))
            ))
            ExtAuthPendingView(store: ExtAuthPendingDomain.Dummies.store(
                for: .extAuthReceived(KKAppDirectory
                    .Entry(name: "Gematik KK", identifier: "identifier"))
            ))
            ExtAuthPendingView(store: ExtAuthPendingDomain.Dummies.store(
                for: .extAuthFailed(ErpAlertState(title: TextState("error")))
            ))
            ExtAuthPendingView(store: ExtAuthPendingDomain.Dummies.store(
                for: .extAuthSuccessful(KKAppDirectory
                    .Entry(name: "Gematik KK", identifier: "identifier"))
            ))
        }
    }
}
