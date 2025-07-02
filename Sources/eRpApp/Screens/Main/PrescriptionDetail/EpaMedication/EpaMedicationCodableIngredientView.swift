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
