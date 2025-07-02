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
import SwiftUI

struct PrescriptionListEmptyView: View {
    @Perception.Bindable var store: StoreOf<PrescriptionListDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                ProfilePictureView(
                    image: store.profile?.image,
                    userImageData: store.profile?.userImageData,
                    color: store.profile?.color,
                    connection: store.profile?.connectionStatus,
                    style: .large
                ) {
                    if let profile = store.profile {
                        store.send(.profilePictureViewTapped(profile))
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
                .padding(.bottom)

                Button(action: {
                    store.send(.refresh)
                }, label: {
                    Text(store.isConnected ? L10n.mainBtnRefresh : L10n.mainBtnLogin)
                })
                    .buttonStyle(.quartary)
                    .padding(.bottom)
                    .accessibilityIdentifier(store.isConnected ? A11y.mainScreen.erxBtnRefresh : A11y.mainScreen
                        .erxBtnLogin)

                Text(L10n.mainEmptyTxtTitle)
                    .font(.headline.weight(.bold))
                    .padding(.vertical, 8)
                    .accessibilityIdentifier(A11y.mainScreen.erxTxtEmptyTitle)

                Text(store.isConnected ? L10n.mainEmptyTxtConnected : L10n.mainEmptyTxtDisconnected)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier(A11y.mainScreen.erxTxtEmptySubtitle)

                if store.hasArchivedPrescriptions {
                    Button {
                        store
                            .send(.showArchivedButtonTapped)
                    } label: {
                        Text(L10n.mainBtnArchivedPresc)
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.top, 28)
                    .accessibilityIdentifier(A11y.mainScreen.erxBtnArcPrescription)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
    }
}

struct EmptyPrescriptionListView_Previews: PreviewProvider {
    static var previews: some View {
        PrescriptionListEmptyView(store: PrescriptionListDomain.Dummies.store)
    }
}
