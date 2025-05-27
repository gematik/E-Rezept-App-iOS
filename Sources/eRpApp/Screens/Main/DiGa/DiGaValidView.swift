//
//  Copyright (c) 2025 gematik GmbH
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
import eRpKit
import eRpStyleKit
import SwiftUI

struct DiGaValidView: View {
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
                    Text(L10n.digaDtlValidTxtHeader)
                        .font(.headline)
                        .padding(.bottom, 8)
                        .accessibilityIdentifier(A11y.digaDetail.digaDtlValidTxtHeader)

                    HStack {
                        Text(store.diGaTask.authoredOn ?? L10n.digaDtlTxtNa.text)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .accessibilityIdentifier(A11y.digaDetail.digaDtlValidTxtStartDate)

                        Image(systemName: SFSymbolName.arrowRight)
                            .foregroundColor(Colors.primary700)

                        Text(store.diGaTask.expiresOnDisplayDate)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .accessibilityIdentifier(A11y.digaDetail.digaDtlValidTxtEndDate)
                    }

                    Text(L10n.digaDtlValidTxtSubheader)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .accessibilityIdentifier(A11y.digaDetail.digaDtlValidTxtSubheader)
                    Spacer()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Colors.systemBackground.ignoresSafeArea())
        }
    }
}

#Preview {
    NavigationStack {
        DiGaValidView(store: DiGaDetailDomain.Dummies.store)
    }
}
