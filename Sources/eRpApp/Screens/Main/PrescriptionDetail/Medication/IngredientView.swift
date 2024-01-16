//
//  Copyright (c) 2024 gematik GmbH
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
import eRpStyleKit
import SwiftUI

struct IngredientView: View {
    let store: IngredientDomain.Store

    var body: some View {
        WithViewStore(store) { $0 } content: { viewStore in
            ScrollView(.vertical) {
                SectionContainer {
                    SubTitle(
                        title: viewStore.text ?? L10n.prscFdTxtNa.text,
                        description: L10n.prscDtlMedIngredientName
                    )
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedIngredientName)

                    SubTitle(
                        title: viewStore.strength ?? L10n.prscFdTxtNa.text,
                        description: L10n.prscDtlMedTxtAmount
                    )
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedIngredientStrength)

                    SubTitle(
                        title: viewStore.form ?? L10n.prscFdTxtNa.text,
                        description: L10n.prscFdTxtDetailsDosageForm
                    )
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedIngredientForm)

                    SubTitle(
                        title: viewStore.number ?? L10n.prscFdTxtNa.text,
                        description: L10n.prscDtlMedTxtIngredinetNumber
                    )
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedIngredientNumber)
                }.sectionContainerStyle(.inline)
            }
            .navigationBarTitle(Text(L10n.prscDtlTxtMedication), displayMode: .inline)
        }
    }
}
