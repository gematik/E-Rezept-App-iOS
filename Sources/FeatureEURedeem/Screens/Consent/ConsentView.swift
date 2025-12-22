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

public struct ConsentView: View {
    @Bindable var store: StoreOf<ConsentDomain>

    public init(store: StoreOf<ConsentDomain>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                // Content
                VStack(alignment: .leading, spacing: 24) {
                    Text(L10n.euredeemConsentTitle)
                        .font(.title.weight(.bold))
                        .foregroundColor(Colors.systemLabel)
                        .padding(.bottom, 8)
                        .accessibilityIdentifier("eu_consent_title")

                    VStack(alignment: .leading, spacing: 24) {
                        Text(L10n.euredeemConsentDescription1)
                            .font(.subheadline)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .accessibilityIdentifier("eu_consent_description_1")

                        Text(L10n.euredeemConsentDescription2)
                            .font(.subheadline)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .accessibilityIdentifier("eu_consent_description_2")
                    }
                }
                .padding(.horizontal)
                .padding(.top, 32)

                Spacer()

                // Info text
                Text(L10n.euredeemConsentInfoText)
                    .font(.subheadline)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                    .accessibilityIdentifier("eu_consent_info_text")

                // Buttons
                VStack(spacing: 8) {
                    Button(
                        action: { store.send(.accept) },
                        label: {
                            Text(L10n.euredeemConsentAcceptButton)
                        }
                    )
                    .buttonStyle(.primaryHugging)
                    .accessibilityIdentifier("eu_consent_accept_button")

                    Button(
                        action: { store.send(.decline) },
                        label: {
                            Text(L10n.euredeemConsentDeclineButton)
                        }
                    )
                    .buttonStyle(.primaryHugging)
                    .accessibilityIdentifier("eu_consent_decline_button")
                }
                .padding(.bottom, 24)
            }
        }
    }
}

struct ConsentView_Previews: PreviewProvider {
    static var previews: some View {
        ConsentView(store: ConsentDomain.Dummies.store)
    }
}
