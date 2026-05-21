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
import eRpResources
import eRpStyleKit
import SwiftUI

public struct ConsentView: View {
    @Bindable var store: StoreOf<ConsentDomain>

    public init(store: StoreOf<ConsentDomain>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Content
                    VStack(alignment: .leading, spacing: 24) {
                        Text(L10n.euredeemConsentTitle)
                            .font(.title.weight(.bold))
                            .foregroundColor(Colors.systemLabel)
                            .padding(.bottom, 8)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityIdentifier(A11y.redeem.eu.consent.eurdmTxtConsentTitle)

                        VStack(alignment: .leading, spacing: 24) {
                            Text(L10n.euredeemConsentDescription1)
                                .font(.subheadline)
                                .foregroundColor(Colors.systemLabelSecondary)
                                .accessibilityIdentifier(A11y.redeem.eu.consent.eurdmTxtConsentDescription1)

                            Text(L10n.euredeemConsentDescription2)
                                .font(.subheadline)
                                .foregroundColor(Colors.systemLabelSecondary)
                                .accessibilityIdentifier(A11y.redeem.eu.consent.eurdmTxtConsentDescription2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 32)
                }
            }

            // Info text
            let infoText = {
                switch store.consentType {
                case .granted:
                    return L10n.euredeemConsentInfoTextGranted
                case .notGranted:
                    return L10n.euredeemConsentInfoTextNotGranted
                case .unknown:
                    return L10n.euredeemConsentInfoText
                }
            }()

            Text(infoText)
                .font(.subheadline)
                .foregroundColor(Colors.systemLabelSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 24)
                .accessibilityIdentifier(A11y.redeem.eu.consent.eurdmTxtConsentInfo)

            // Buttons
            VStack(spacing: 8) {
                Button(
                    action: { store.send(.accept) },
                    label: {
                        Text(L10n.euredeemConsentAcceptButton)
                    }
                )
                .buttonStyle(.primary(
                    isEnabled: store.consentType != .granted,
                    width: .wideHugging
                ))
                .disabled(store.consentType == .granted)
                .accessibilityIdentifier(A11y.redeem.eu.consent.eurdmBtnConsentAccept)

                Button(
                    action: { store.send(.decline) },
                    label: {
                        Text(L10n.euredeemConsentDeclineButton)
                    }
                )
                .buttonStyle(.primary(
                    isEnabled: store.consentType != .notGranted,
                    width: .wideHugging
                ))
                .disabled(store.consentType == .notGranted)
                .accessibilityIdentifier(A11y.redeem.eu.consent.eurdmBtnConsentDecline)
            }
            .padding(.bottom, 24)
        }
        .navigationBarItems(
            trailing: Button {
                store.send(.delegate(.close))
            } label: {
                Text(L10n.navCancel)
            }
            .accessibility(identifier: A11y.redeem.eu.consent.eurdmBtnConsentAbort)
            .accessibility(label: Text(L10n.euredeemConsentAbortButton))
        )
        .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
    }
}

struct ConsentView_Previews: PreviewProvider {
    static var previews: some View {
        ConsentView(store: ConsentDomain.Dummies.store)
    }
}
