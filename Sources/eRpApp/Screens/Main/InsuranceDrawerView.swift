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
import eRpKit
import eRpStyleKit
import SwiftUI
import SwiftUIIntrospect

enum RootView {
    case main
    case settings
}

struct InsuranceDrawerView: View {
    let root: RootView
    let closeDrawerAction: () -> Void
    let gkvInsuredAction: () -> Void
    let pkvInsuredAction: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            HStack {
                Spacer()
                CloseButton {
                    closeDrawerAction()
                }
            }

            Image(decorative: Asset.Illustrations.mannkarteCircleBlue)

            VStack(alignment: .center, spacing: 8) {
                Text(root == .main ? L10n.mainInsuranceDrawerTxtHeader : L10n.stgInsuranceDrawerTxtHeader)
                    .fontWeight(.semibold)

                Text(root == .main ? L10n.mainInsuranceDrawerTxtFooter : L10n.stgInsuranceDrawerTxtFooter)
                    .foregroundColor(Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .center, spacing: 16) {
                Button {
                    gkvInsuredAction()
                } label: {
                    Text(L10n.wlcdBtnGkv)
                }
                .buttonStyle(.primary)
                .accessibility(identifier: A11y.welcomedrawer.wlcdBtnGkvUser)

                Button(action: {
                    pkvInsuredAction()
                }, label: {
                    Text(L10n.wlcdBtnPkv)
                        .foregroundColor(Colors.primary700)
                        .fontWeight(.semibold)
                })
                    .buttonStyle(.tertiary)
                    .accessibility(identifier: A11y.welcomedrawer.wlcdBtnPkvUser)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8) // capsule padding
        .padding(.horizontal)
        .background(Colors.systemBackground.ignoresSafeArea(.all, edges: .bottom))
    }
}

#Preview {
    NavigationStack {
        InsuranceDrawerView(root: .main) {} gkvInsuredAction: {} pkvInsuredAction: {}
    }
}
