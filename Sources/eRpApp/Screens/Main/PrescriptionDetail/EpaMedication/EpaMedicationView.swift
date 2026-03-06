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

struct EpaMedicationView: View {
    @Bindable var store: StoreOf<EpaMedicationDomain>

    var body: some View {
        ScrollView(.vertical) {
            SectionContainer(
                content: {
                    LabeledContent {
                        Text(store.epaMedication?.displayName ?? L10n.prscTxtFallbackName.text)
                    } label: {
                        Text(L10n.prscDtlMedTxtName)
                    }
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedName)

                    if let ingredients = store.epaMedication?.ingredients {
                        ForEach(ingredients, id: \.self) { (ingredient: EpaMedicationIngredient) in
                            Button(
                                action: { store.send(.showIngredient(ingredient)) },
                                label: {
                                    LabeledContent {
                                        Text(ingredient.name ?? L10n.prscTxtFallbackName.text)
                                    } label: {
                                        Text(L10n.prscDtlMedIngredientName)
                                    }
                                }
                            )
                            .buttonStyle(.navigation)
                            .modifier(SectionContainerCellModifier())
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedBtnIngredient)
                        }
                    }

                    if let amount = store.epaMedication?.amount?.description {
                        LabeledContent {
                            Text(amount)
                        } label: {
                            Text(L10n.prscDtlMedTxtAmount)
                        }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedAmount)
                    }

                    if let normSizeCode = store.epaMedication?.normSizeCode {
                        LabeledContent {
                            Text(normSizeCode)
                        } label: {
                            Text(L10n.prscFdTxtDetailsDose)
                        }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedNormSizeCode)
                    }

                    if let pzn = store.epaMedication?.pzn {
                        LabeledContent {
                            Text(pzn)
                        } label: {
                            Text(L10n.prscFdTxtDetailsPzn)
                        }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedPzn)
                    }

                    if let dosageForm = store.epaMedication?.localizedDosageForm {
                        LabeledContent {
                            Text(dosageForm)
                        } label: {
                            Text(L10n.prscFdTxtDetailsDosageForm)
                        }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDosageForm)
                    }

                    if let drugCategory = store.epaMedication?.drugCategory?.localizedName {
                        LabeledContent {
                            Text(drugCategory)
                        } label: {
                            Text(L10n.prscDtlMedTxtDrugCategory)
                        }
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDrugCategory)
                    }

                    if let isVaccine = store.epaMedication?.isVaccine {
                        LabeledContent {
                            Text(isVaccine ? L10n.prscDtlTxtYes : L10n.prscDtlTxtNo)
                        } label: {
                            Text(L10n.prscDtlMedTxtDrugVaccine)
                        }

                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedVaccine)
                    }

                    if let instructions = store.epaMedication?.manufacturingInstructions {
                        LabeledContent {
                            Text(instructions)
                        } label: {
                            Text(L10n.prscDtlMedManufacturingInstructions)
                        }
                        .modifier(SectionContainerCellModifier())
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedManufacturingInstructions)
                    }

                    if let packaging = store.epaMedication?.packaging {
                        LabeledContent {
                            Text(packaging)
                        } label: {
                            Text(L10n.prscDtlMedTxtPackaging)
                        }
                        .modifier(SectionContainerCellModifier())
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedPackaging)
                    }
                },
                moreContent: {
                    if let dispenseState = store.dispenseState {
                        DispenseDetailView(dispenseDetail: dispenseState)
                    }
                }
            ).sectionContainerStyle(.inline)
        }
        .navigationBarTitle(Text(L10n.prscDtlTxtMedication), displayMode: .inline)
        // IngredientViews
        .navigationDestination(
            item: $store.scope(state: \.destination?.codableIngredient, action: \.destination.codableIngredient),
            destination: EpaMedicationCodableIngredientView.init(store:)
        )
        .navigationDestination(
            item: $store.scope(
                state: \.destination?.medicationIngredient,
                action: \.destination.medicationIngredient
            ),
            destination: EpaMedicationView.init(store:)
        )
    }

    struct DispenseDetailView: View {
        let dispenseDetail: EpaMedicationDomain.State.DispenseState
        var body: some View {
            if let expiresOn = dispenseDetail.expiresOn {
                LabeledContent {
                    Text(expiresOn)
                } label: {
                    Text(L10n.prscDtlMedTxtBatchExpiresOn)
                }
                .modifier(SectionContainerCellModifier())
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedBatchExpiresOn)
            }

            if let lotNumber = dispenseDetail.lotNumber {
                LabeledContent {
                    Text(lotNumber)
                } label: {
                    Text(L10n.prscDtlMedTxtBatchLotNumber)
                }
                .modifier(SectionContainerCellModifier())
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedBatchLotNumber)
            }

            if let dosageInstruction = dispenseDetail.dosageInstruction {
                LabeledContent {
                    Text(dosageInstruction)
                } label: {
                    Text(L10n.prscDtlTxtDosageInstructions)
                }

                .modifier(SectionContainerCellModifier())
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDosageInstructions)
            }

            if let noteText = dispenseDetail.noteText {
                LabeledContent {
                    Text(noteText)
                } label: {
                    Text(L10n.prscDtlMedTxtNote)
                }

                .modifier(SectionContainerCellModifier())
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedNote)
            }

            if let quantity = dispenseDetail.quantity?.description {
                LabeledContent {
                    Text(quantity)
                } label: {
                    Text(L10n.prscDtlMedTxtAmount)
                }

                .modifier(SectionContainerCellModifier())
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedAmount)
            }

            if let whenHandedOver = dispenseDetail.whenHandedOver {
                LabeledContent {
                    Text(whenHandedOver)
                } label: {
                    Text(L10n.prscDtlMedTxtHandedOverDate)
                }

                .modifier(SectionContainerCellModifier())
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedHandedOverDate)
            }
        }
    }
}

extension EpaMedicationDrugCategory {
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
        }
    }
}

#Preview("Medicinal Product Package (Rezeptur)") {
    NavigationStack {
        EpaMedicationView(
            store: .init(
                initialState: .init(subscribed: ErxEpaMedication.Dummies.medicinalProductPackage)
            ) {
                EpaMedicationDomain()
            }
        )
    }
}

#Preview("Extemporaneous Preparation (Kombipackung)") {
    NavigationStack {
        EpaMedicationView(
            store: .init(
                initialState: .init(subscribed: ErxEpaMedication.Dummies.extemporaneousPreparation)
            ) {
                EpaMedicationDomain()
            }
        )
    }
}

#Preview("Simple ErxEpaMedication") {
    NavigationStack {
        EpaMedicationView(
            store: .init(
                initialState: .init(subscribed: ErxEpaMedication.Dummies.simpleMedication)
            ) {
                EpaMedicationDomain()
            }
        )
    }
}
