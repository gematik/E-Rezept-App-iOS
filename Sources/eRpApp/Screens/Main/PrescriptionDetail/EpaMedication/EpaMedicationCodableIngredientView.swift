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

struct EpaMedicationCodableIngredientView: View {
    @Perception.Bindable var store: StoreOf<EpaMedicationCodableIngredientDomain>

    var body: some View {
        WithPerceptionTracking {
            ScrollView(.vertical) {
                SectionContainer {
                    SubTitle(
                        title: store.displayName,
                        description: L10n.prscDtlMedIngredientName
                    )
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedIngredientName)

                    SubTitle(
                        title: store.strengthText,
                        description: L10n.prscDtlMedTxtAmount
                    )
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedIngredientStrength)

                    SubTitle(
                        title: store.form,
                        description: L10n.prscFdTxtDetailsDosageForm
                    )
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedIngredientForm)

                    SubTitle(
                        title: store.number,
                        description: L10n.prscDtlMedTxtIngredinetNumber
                    )
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedIngredientNumber)
                }.sectionContainerStyle(.inline)
            }
            .navigationBarTitle(Text(L10n.prscDtlTxtMedication), displayMode: .inline)
        }
    }
}

#Preview("Natriumcromoglicat") {
    EpaMedicationCodableIngredientView(
        store: .init(
            initialState: EpaMedicationCodableIngredientDomain.Dummies.state
        ) {
            EpaMedicationCodableIngredientDomain()
        }
    )
}
