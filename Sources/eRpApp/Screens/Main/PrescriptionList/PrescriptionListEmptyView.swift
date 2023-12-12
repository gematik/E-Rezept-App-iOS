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
import SwiftUI

struct PrescriptionListEmptyView: View {
    let store: PrescriptionListDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, PrescriptionListDomain.Action>

    init(store: PrescriptionListDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let profile: UserProfile?
        let isConnected: Bool
        let hasArchivedPrescriptions: Bool

        init(state: PrescriptionListDomain.State) {
            profile = state.profile
            isConnected = profile?.connectionStatus == .connected
            hasArchivedPrescriptions = state.prescriptions.first(where: \.isArchived) != nil
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ProfilePictureView(
                image: viewStore.profile?.image,
                userImageData: viewStore.profile?.userImageData,
                color: viewStore.profile?.color,
                connection: viewStore.profile?.connectionStatus,
                style: .large
            ) {
                if let profile = viewStore.profile {
                    viewStore.send(.profilePictureViewTapped(profile))
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .padding(.bottom)

            Button(action: {
                viewStore.send(.refresh)
            }, label: {
                Text(viewStore.isConnected ? L10n.mainBtnRefresh : L10n.mainBtnLogin)
            })
                .buttonStyle(.quartary)
                .padding(.bottom)
                .accessibilityIdentifier(viewStore.isConnected ? A11y.mainScreen.erxBtnRefresh : A11y.mainScreen
                    .erxBtnLogin)

            Text(L10n.mainEmptyTxtTitle)
                .font(.headline.weight(.bold))
                .padding(.vertical, 8)
                .accessibilityIdentifier(A11y.mainScreen.erxTxtEmptyTitle)

            Text(viewStore.isConnected ? L10n.mainEmptyTxtConnected : L10n.mainEmptyTxtDisconnected)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier(A11y.mainScreen.erxTxtEmptySubtitle)

            if viewStore.hasArchivedPrescriptions {
                Button {
                    viewStore
                        .send(.showArchivedButtonTapped)
                } label: {
                    Text(L10n.mainBtnArchivedPresc)
                        .font(.subheadline.weight(.semibold))
                }
                .padding(.top, 28)
                .accessibilityIdentifier(A11y.mainScreen.erxBtnScnPrescription)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct EmptyPrescriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        PrescriptionListEmptyView(store: PrescriptionListDomain.Dummies.store)
    }
}
