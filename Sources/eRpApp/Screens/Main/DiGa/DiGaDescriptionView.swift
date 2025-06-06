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

struct DiGaDescriptionView: View {
    @Perception.Bindable var store: StoreOf<DiGaDetailDomain>

    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(L10n.digaDtlDescriptionTxtHeader)
                        .accessibilityIdentifier(A11y.digaDetail.digaDtlDescriptionTxtHeader)
                    Text(store.bfarmDiGaDetails?.description ?? L10n.prscFdTxtNa.text)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color(.secondaryLabel))
                        .accessibilityIdentifier(A11y.digaDetail.digaDtlDescriptionTxtDesc)
                }.padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.navigationBarTitle(Text(L10n.digaDtlDescriptionTxtNavTitle), displayMode: .inline)
        }
    }
}

#Preview {
    NavigationStack {
        DiGaValidView(store: DiGaDetailDomain.Dummies.store)
    }
}
