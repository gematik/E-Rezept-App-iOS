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

import Combine
import ComposableArchitecture
import ConsentService
import eRpKit
import eRpResources
import eRpStyleKit
import SwiftUI
import SwiftUIIntrospect

struct EURedeemConsentDrawerView: View {
    let consentCheck: ConsentService.CheckResult
    let grantConsentAction: () -> Void
    let revokeConsentAction: () -> Void

    var body: some View {
        VStack(alignment: .center) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Colors.systemLabelSecondary)
            Button {
                grantConsentAction()
            } label: {
                Text(L10n.euredeemConsentDrawerBtnAccept)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.primary(isEnabled: consentCheck != .granted))
            .disabled(consentCheck == .granted)
            .accessibility(identifier: A11y.redeem.eu.consent.rdmBtnEuConsentGrant)

            Button(action: {
                revokeConsentAction()
            }, label: {
                Text(L10n.euredeemConsentDrawerBtnRevoke)
                    .fontWeight(.semibold)
            })
                .buttonStyle(.primary(isEnabled: consentCheck != .notGranted))
                .disabled(consentCheck == .notGranted)
                .accessibility(identifier: A11y.redeem.eu.consent.rdmBtnEuConsentRevoke)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8) // capsule padding
        .padding(.horizontal)
        .background(Colors.systemBackground.ignoresSafeArea(.all, edges: .bottom))
    }

    private var title: String {
        switch consentCheck {
        case .granted:
            return L10n.euredeemConsentDrawerTitleGranted.text
        case .notGranted:
            return L10n.euredeemConsentDrawerTitleNotGranted.text
        case .notAuthenticated, .error:
            return L10n.euredeemConsentDrawerTitleUnknown.text
        }
    }
}

#Preview {
    NavigationStack {
        InsuranceDrawerView(root: .main) {} gkvInsuredAction: {} pkvInsuredAction: {} federalInsuredAction: {}
    }
}
