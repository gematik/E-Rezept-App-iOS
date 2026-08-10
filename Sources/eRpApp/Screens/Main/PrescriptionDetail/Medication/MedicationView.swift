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
import FeatureHelpers
import SwiftUI

struct MedicationView: View {
    @Bindable var store: StoreOf<MedicationDomain>

    var body: some View {
        ScrollView(.vertical) {
            switch store.medication?.profile {
            case .pzn, .unknown, .none:
                PznMedicationView(medication: store.medication, dispenseState: store.dispenseState)
            case .freeText:
                FreeTextMedicationView(medication: store.medication, dispenseState: store.dispenseState)
            case .ingredient, .compounding:
                CompoundingMedicationView(store: store)
            }
        }
        .navigationBarTitle(Text(L10n.prscDtlTxtMedication), displayMode: .inline)
        // IngredientView
        .navigationDestination(
            item: $store.scope(state: \.destination?.ingredient, action: \.destination.ingredient)
        ) { store in
            IngredientView(store: store)
        }
    }

    struct PznMedicationView: View {
        let medication: ErxMedication?
        let dispenseState: MedicationDomain.State.DispenseState?

        var body: some View {
            SectionContainer {
                LabeledContent {
                    Text(medication?.displayName ?? L10n.prscTxtFallbackName.text)
                } label: {
                    Text(L10n.prscDtlMedTxtName)
                }
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedName)

                if let amount = medication?.amount?.description {
                    LabeledContent { Text(amount) } label: { Text(L10n.prscDtlMedTxtAmount) }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedAmount)
                }

                if let normSizeCode = medication?.normSizeCode {
                    LabeledContent { Text(normSizeCode) } label: { Text(L10n.prscFdTxtDetailsDose) }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedNormSizeCode)
                }

                if let pzn = medication?.pzn {
                    LabeledContent { Text(pzn) } label: { Text(L10n.prscFdTxtDetailsPzn) }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedPzn)
                }

                if let dosageForm = medication?.localizedDosageForm {
                    LabeledContent { Text(dosageForm) } label: { Text(L10n.prscFdTxtDetailsDosageForm) }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDosageForm)
                }

                if let drugCategory = medication?.drugCategory?.localizedName {
                    LabeledContent { Text(drugCategory) } label: { Text(L10n.prscDtlMedTxtDrugCategory) }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDrugCategory)
                }

                if let isVaccine = medication?.isVaccine {
                    LabeledContent {
                        Text(isVaccine ? L10n.prscDtlTxtYes : L10n.prscDtlTxtNo)
                    } label: {
                        Text(L10n.prscDtlMedTxtDrugVaccine)
                    }
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedVaccine)
                }

                if let dispenseState {
                    DispenseDetailView(dispenseDetail: dispenseState)
                }
            }.sectionContainerStyle(.inline)
        }
    }

    struct FreeTextMedicationView: View {
        let medication: ErxMedication?
        let dispenseState: MedicationDomain.State.DispenseState?

        var body: some View {
            SectionContainer {
                LabeledContent {
                    Text(medication?.displayName ?? L10n.prscTxtFallbackName.text)
                } label: {
                    Text(L10n.prscDtlMedTxtName)
                }
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedName)

                if let amount = medication?.amount?.description {
                    LabeledContent { Text(amount) } label: { Text(L10n.prscDtlMedTxtAmount) }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedAmount)
                }

                if let normSizeCode = medication?.normSizeCode {
                    LabeledContent { Text(normSizeCode) } label: { Text(L10n.prscFdTxtDetailsDose) }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedNormSizeCode)
                }

                if let dosageForm = medication?.localizedDosageForm {
                    LabeledContent { Text(dosageForm) } label: { Text(L10n.prscFdTxtDetailsDosageForm) }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDosageForm)
                }

                if let drugCategory = medication?.drugCategory?.localizedName {
                    LabeledContent { Text(drugCategory) } label: { Text(L10n.prscDtlMedTxtDrugCategory) }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDrugCategory)
                }

                if let isVaccine = medication?.isVaccine {
                    LabeledContent {
                        Text(isVaccine ? L10n.prscDtlTxtYes : L10n.prscDtlTxtNo)
                    } label: {
                        Text(L10n.prscDtlMedTxtDrugVaccine)
                    }
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedVaccine)
                }

                if let dispenseState {
                    DispenseDetailView(dispenseDetail: dispenseState)
                }
            }.sectionContainerStyle(.inline)
        }
    }

    struct CompoundingMedicationView: View {
        @Bindable var store: StoreOf<MedicationDomain>

        var body: some View {
            SectionContainer {
                if let ingredients = store.medication?.ingredients {
                    ForEach(ingredients, id: \.self) { ingredient in
                        Button(action: { store.send(.showIngredient(ingredient)) }, label: {
                            LabeledContent {
                                Text(ingredient.text ?? L10n.prscTxtFallbackName.text)
                            } label: {
                                Text(L10n.prscDtlMedIngredientName)
                            }
                        })
                        .buttonStyle(.navigation)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedBtnIngredient)
                    }
                }

                if let amount = store.medication?.amount?.description {
                    LabeledContent {
                        Text(amount)
                    } label: {
                        Text(L10n.prscDtlMedTxtAmount)
                    }
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedAmount)
                }

                if let normSizeCode = store.medication?.normSizeCode {
                    LabeledContent {
                        Text(normSizeCode)
                    } label: {
                        Text(L10n.prscFdTxtDetailsDose)
                    }
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedNormSizeCode)
                }

                if let dosageForm = store.medication?.localizedDosageForm {
                    LabeledContent {
                        Text(dosageForm)
                    } label: {
                        Text(L10n.prscFdTxtDetailsDosageForm)
                    }
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDosageForm)
                }

                if let drugCategory = store.medication?.drugCategory?.localizedName {
                    LabeledContent {
                        Text(drugCategory)
                    } label: {
                        Text(L10n.prscDtlMedTxtDrugCategory)
                    }
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDrugCategory)
                }

                if let isVaccine = store.medication?.isVaccine {
                    LabeledContent {
                        Text(isVaccine ? L10n.prscDtlTxtYes : L10n.prscDtlTxtNo)
                    } label: {
                        Text(L10n.prscDtlMedTxtDrugVaccine)
                    }
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedVaccine)
                }

                if let instructions = store.medication?.manufacturingInstructions {
                    LabeledContent {
                        Text(instructions)
                    } label: {
                        Text(L10n.prscDtlMedManufacturingInstructions)
                    }
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedManufacturingInstructions)
                }

                if let packaging = store.medication?.packaging {
                    LabeledContent {
                        Text(packaging)
                    } label: {
                        Text(L10n.prscDtlMedTxtPackaging)
                    }
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedPackaging)
                }

                if let dispenseState = store.dispenseState {
                    DispenseDetailView(dispenseDetail: dispenseState)
                }

            }.sectionContainerStyle(.inline)
        }
    }

    struct DispenseDetailView: View {
        let dispenseDetail: MedicationDomain.State.DispenseState
        var body: some View {
            if let expiresOn = dispenseDetail.expiresOn {
                LabeledContent {
                    Text(expiresOn)
                } label: {
                    Text(L10n.prscDtlMedTxtBatchExpiresOn)
                }
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedBatchExpiresOn)
            }

            if let lotNumber = dispenseDetail.lotNumber {
                LabeledContent {
                    Text(lotNumber)
                } label: {
                    Text(L10n.prscDtlMedTxtBatchLotNumber)
                }
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedBatchLotNumber)
            }

            if let dosageInstruction = dispenseDetail.dosageInstruction {
                LabeledContent {
                    Text(dosageInstruction)
                } label: {
                    Text(L10n.prscDtlTxtDosageInstructions)
                }
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDosageInstructions)
            }

            if let noteText = dispenseDetail.noteText {
                LabeledContent {
                    Text(noteText)
                } label: {
                    Text(L10n.prscDtlMedTxtNote)
                }
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedNote)
            }

            if let quantity = dispenseDetail.quantity?.description {
                LabeledContent {
                    Text(quantity)
                } label: {
                    Text(L10n.prscDtlMedTxtAmount)
                }
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedAmount)
            }

            if let whenHandedOver = dispenseDetail.whenHandedOver {
                LabeledContent {
                    Text(whenHandedOver)
                } label: {
                    Text(L10n.prscDtlMedTxtHandedOverDate)
                }
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedHandedOverDate)
            }
        }
    }
}

extension ErxMedication.DrugCategory {
    var localizedName: String {
        switch self {
        case .avm:
            return L10n.prscDtlMedTxtAvm.text
        case .btm:
            return L10n.prscDtlMedTxtBtm.text
        case .amvv:
            return L10n.prscDtlMedTxtAmvv.text
        case .other:
            return L10n.prscDtlMedTxtOther.text
        case .unknown:
            return L10n.prscFdTxtNa.text
        }
    }
}

struct MedicationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // PZN
            NavigationStack {
                MedicationView(
                    store: .init(
                        initialState: .init(subscribed: ErxTask.Demo.pznMedication)
                    ) {
                        MedicationDomain()
                    }
                )
            }
            // Freetext
            NavigationStack {
                MedicationView(
                    store: .init(
                        initialState: .init(subscribed: ErxTask.Demo.freeTextMedication)
                    ) {
                        MedicationDomain()
                    }
                )
            }.preferredColorScheme(.dark)

            // Ingredient/Compounding
            NavigationStack {
                MedicationView(
                    store: .init(
                        initialState: .init(subscribed: ErxTask.Demo.compoundingMedication)
                    ) {
                        MedicationDomain()
                    }
                )
            }.preferredColorScheme(.dark)

            // Dispensed Ingredient/Compounding
            NavigationStack {
                MedicationView(
                    store: .init(
                        initialState: .init(
                            dispensed: ErxMedicationDispense.Demo.demoMedicationDispense,
                            dateFormatter: UIDateFormatter.previewValue
                        )
                    ) {
                        MedicationDomain()
                    }
                )
            }
        }
    }
}
