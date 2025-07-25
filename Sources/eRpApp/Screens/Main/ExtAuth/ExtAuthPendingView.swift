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
import eRpStyleKit
import IDP
import SwiftUI

struct ExtAuthPendingView: View {
    @Perception.Bindable var store: ExtAuthPendingDomain.Store

    var background: Color {
        switch store.state.extAuthState {
        case .extAuthFailed:
            return Colors.red300
        default:
            return Color(.secondarySystemBackground)
        }
    }

    @ViewBuilder func text() -> some View {
        let name = store.state.extAuthState.entry?.name ?? ""

        switch store.state.extAuthState {
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

    @ViewBuilder func icon() -> some View {
        switch store.state.extAuthState {
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
        switch store.state.extAuthState {
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
        WithPerceptionTracking {
            VStack {
                Spacer()
                    .alert($store.scope(state: \.destination?.extAuthAlert?.alert, action: \.destination.extAuthAlert))
                if showToast {
                    HStack(spacing: 16) {
                        icon()

                        text()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button(action: {
                            store.send(.cancelAllPendingRequests, animation: .easeInOut)
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
            .task {
                await store.send(.registerListener).finish()
            }
        }
    }
}

struct ExtAuthPendingView_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            ExtAuthPendingView(store: ExtAuthPendingDomain.Dummies.store(
                for: .init(extAuthState: .empty)
            ))
            ExtAuthPendingView(store: ExtAuthPendingDomain.Dummies.store(
                for: .init(extAuthState: .pendingExtAuth(KKAppDirectory
                        .Entry(name: "Gematik KK", identifier: "identifier")))
            ))
            ExtAuthPendingView(store: ExtAuthPendingDomain.Dummies.store(
                for: .init(extAuthState: .extAuthReceived(KKAppDirectory
                        .Entry(name: "Gematik KK", identifier: "identifier")))
            ))
            ExtAuthPendingView(store: ExtAuthPendingDomain.Dummies.store(
                for: .init(extAuthState: .extAuthFailed)
            ))
            ExtAuthPendingView(store: ExtAuthPendingDomain.Dummies.store(
                for: .init(extAuthState: .extAuthSuccessful(KKAppDirectory
                        .Entry(name: "Gematik KK", identifier: "identifier")))
            ))
        }
    }
}
