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

struct WelcomeDrawerView: View {
    let store: StoreOf<MainDomain>

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Capsule()
                .foregroundColor(Colors.systemLabelQuarternary)
                .frame(width: 32, height: 8, alignment: .center)

            Image(decorative: Asset.Illustrations.mannkarteCircleBlue)

            VStack(alignment: .center, spacing: 8) {
                Text(L10n.wlcdTxtHeader)
                    .fontWeight(.semibold)

                Text(L10n.wlcdTxtFooter)
                    .foregroundColor(Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .center, spacing: 16) {
                Button {
                    store.send(.startCardWall, animation: .easeInOut)
                } label: {
                    Text(L10n.wlcdBtnLogin)
                }
                .buttonStyle(.primaryHugging)
                .accessibility(identifier: A11y.welcomedrawer.wlcdBtnLogin)

                Button(action: {
                    store.send(.setNavigation(tag: .none), animation: .easeInOut)
                }, label: {
                    Text(L10n.wlcdBtnDecline)
                        .foregroundColor(Colors.primary700)
                        .fontWeight(.semibold)
                })
                    .frame(minHeight: 52, alignment: .center) // quaternary button minHeight
                    .accessibility(identifier: A11y.welcomedrawer.wlcdBtnDecline)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8) // capsule padding
        .padding(.horizontal)
        .background(Colors.systemBackground.ignoresSafeArea(.all, edges: .bottom))
    }
}

struct WelcomeDrawerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WelcomeDrawerView(store: MainDomain.Dummies.store)
        }
    }
}
