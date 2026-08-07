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
import SwiftUI

struct EuRevokeView: View {
    @Bindable var store: StoreOf<OrderDetailDomain>

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Spacer()
                CloseButton {
                    store.send(.resetNavigation)
                }
            }
            .padding(.horizontal)

            ScrollView {
                VStack(alignment: .center, spacing: 24) {
                    if store.isDeleted {
                        Image(systemName: SFSymbolName.checkmarkCircle)
                            .font(.system(size: 48))
                            .foregroundColor(Colors.secondary700)

                        Text(L10n.ordDetailEuRevokeTxtRevokeTitle)
                            .bold()

                        Text(L10n.ordDetailEuRevokeTxtRevokeMessage)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Colors.systemLabelSecondary)
                    } else {
                        Image(decorative: Asset.EUReedem.euFlag)
                            .frame(width: 48, height: 48, alignment: .center)

                        VStack(spacing: 8) {
                            Text(L10n.ordDetailEuRevokeTxtValidTitle)
                                .bold()

                            Text(L10n.ordDetailEuRevokeTxtValidMessage)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Colors.systemLabelSecondary)

                            Button {
                                store.send(.euRevokePermission)
                            } label: {
                                Text(L10n.ordDetailEuRevokeBtnRevokeCode)
                            }
                            .buttonStyle(.primary)
                            .accessibility(identifier: A11y.welcomedrawer.wlcdBtnGkvUser)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8) // capsule padding
        .background(Colors.systemBackground.ignoresSafeArea(.all, edges: .bottom))
    }
}
