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
import eRpKit
import eRpStyleKit
import SwiftUI

struct DiGaDuesInfoView: View {
    @Perception.Bindable var store: StoreOf<DiGaDetailDomain>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        store.send(.setNavigation(tag: .none))
                    } label: {
                        Image(systemName: SFSymbolName.crossIconPlain)
                            .font(Font.caption.weight(.bold))
                            .foregroundColor(Color(.label))
                            .padding(12)
                            .background(Circle().foregroundColor(Color(.systemGray6)))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.digaDtlDuesTxtHeader)
                        .font(.headline)
                        .accessibilityIdentifier(A11y.digaDetail.digaDtlSupportTxtHeader)

                    Text(L10n.digaDtlDuesTxtInfo)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .accessibilityIdentifier(A11y.digaDetail.digaDtlSupportTxtProvidedLink)

                    Text(L10n.digaDtlDuesTxtInfoDate)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .padding(.bottom, 16)
                    Spacer()
                }
            }
            .accessibilityIdentifier(A11y.digaDetail.digaDtlSupportBtnOpenLink)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Colors.systemBackground.ignoresSafeArea())
        }
    }
}

#Preview {
    NavigationStack {
        DiGaSupportView(store: DiGaDetailDomain.Dummies.store)
    }
}
