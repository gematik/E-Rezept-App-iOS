//
//  Copyright (c) 2023 gematik GmbH
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

struct MedicationView: View {
    let store: StoreOf<MedicationDomain>
    @ObservedObject var viewStore: ViewStore<MedicationDomain.State, MedicationDomain.Action>

    init(store: StoreOf<MedicationDomain>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        ScrollView(.vertical) {
            switch viewStore.medication?.profile {
            case .pzn, .unknown, .none:
                PznMedicationView(medication: viewStore.medication, dispenseState: viewStore.dispenseState)
            case .freeText:
                FreeTextMedicationView(medication: viewStore.medication, dispenseState: viewStore.dispenseState)
            case .ingredient, .compounding:
                CompoundingMedicationView(store: store)
            }

            // IngredientView
            NavigationLink(
                destination: IfLetStore(
                    store.destinationsScope(state: /MedicationDomain.Destinations.State.ingredient),
                    then: IngredientView.init(store:)
                ),
                tag: MedicationDomain.Destinations.State.Tag.ingredient,
                selection: viewStore.binding(
                    get: \.destination?.tag,
                    send: MedicationDomain.Action.setNavigation
                )
            ) {
                EmptyView()
            }.accessibility(hidden: true)
        }
        .navigationBarTitle(Text(L10n.prscDtlTxtMedication), displayMode: .inline)
    }

    struct PznMedicationView: View {
        let medication: ErxMedication?
        let dispenseState: MedicationDomain.State.DispenseState?

        var body: some View {
            SectionContainer {
                SubTitle(
                    title: medication?.displayName ?? L10n.prscTxtFallbackName.text,
                    description: L10n.prscDtlMedTxtName
                )
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedName)

                if let amount = medication?.amount?.description {
                    SubTitle(title: amount, description: L10n.prscDtlMedTxtAmount)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedAmount)
                }

                if let normSizeCode = medication?.normSizeCode {
                    SubTitle(title: normSizeCode, description: L10n.prscFdTxtDetailsDose)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedNormSizeCode)
                }

                if let pzn = medication?.pzn {
                    SubTitle(title: pzn, description: L10n.prscFdTxtDetailsPzn)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedPzn)
                }

                if let dosageForm = medication?.localizedDosageForm {
                    SubTitle(title: dosageForm, description: L10n.prscFdTxtDetailsDosageForm)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDosageForm)
                }

                if let drugCategory = medication?.drugCategory?.localizedName {
                    SubTitle(title: drugCategory, description: L10n.prscDtlMedTxtDrugCategory)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDrugCategory)
                }

                if let isVaccine = medication?.isVaccine {
                    SubTitle(
                        title: isVaccine ? L10n.prscDtlTxtYes : L10n.prscDtlTxtNo,
                        description: L10n.prscDtlMedTxtDrugVaccine
                    )
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedVaccine)
                }

                if let dispenseState = dispenseState {
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
                SubTitle(
                    title: medication?.displayName ?? L10n.prscTxtFallbackName.text,
                    description: L10n.prscDtlMedTxtName
                )
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedName)

                if let amount = medication?.amount?.description {
                    SubTitle(title: amount, description: L10n.prscDtlMedTxtAmount)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedAmount)
                }

                if let normSizeCode = medication?.normSizeCode {
                    SubTitle(title: normSizeCode, description: L10n.prscFdTxtDetailsDose)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedNormSizeCode)
                }

                if let dosageForm = medication?.localizedDosageForm {
                    SubTitle(title: dosageForm, description: L10n.prscFdTxtDetailsDosageForm)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDosageForm)
                }

                if let drugCategory = medication?.drugCategory?.localizedName {
                    SubTitle(title: drugCategory, description: L10n.prscDtlMedTxtDrugCategory)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDrugCategory)
                }

                if let isVaccine = medication?.isVaccine {
                    SubTitle(
                        title: isVaccine ? L10n.prscDtlTxtYes : L10n.prscDtlTxtNo,
                        description: L10n.prscDtlMedTxtDrugVaccine
                    )
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedVaccine)
                }

                if let dispenseState = dispenseState {
                    DispenseDetailView(dispenseDetail: dispenseState)
                }
            }.sectionContainerStyle(.inline)
        }
    }

    struct CompoundingMedicationView: View {
        @ObservedObject
        var viewStore: ViewStore<MedicationDomain.State, MedicationDomain.Action>

        init(store: Store<MedicationDomain.State, MedicationDomain.Action>) {
            viewStore = ViewStore(store)
        }

        var body: some View {
            SectionContainer {
                if let ingredients = viewStore.medication?.ingredients {
                    ForEach(ingredients, id: \.self) { ingredient in
                        Button(action: { viewStore.send(.showIngredient(ingredient)) }, label: {
                            SubTitle(
                                title: ingredient.text ?? L10n.prscTxtFallbackName.text,
                                details: L10n.prscDtlMedIngredientName
                            )
                        })
                            .buttonStyle(.navigation)
                            .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedBtnIngredient)
                    }
                }

                if let amount = viewStore.medication?.amount?.description {
                    SubTitle(title: amount, description: L10n.prscDtlMedTxtAmount)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedAmount)
                }

                if let normSizeCode = viewStore.medication?.normSizeCode {
                    SubTitle(title: normSizeCode, description: L10n.prscFdTxtDetailsDose)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedNormSizeCode)
                }

                if let dosageForm = viewStore.medication?.localizedDosageForm {
                    SubTitle(title: dosageForm, description: L10n.prscFdTxtDetailsDosageForm)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDosageForm)
                }

                if let drugCategory = viewStore.medication?.drugCategory?.localizedName {
                    SubTitle(title: drugCategory, description: L10n.prscDtlMedTxtDrugCategory)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDrugCategory)
                }

                if let isVaccine = viewStore.medication?.isVaccine {
                    SubTitle(
                        title: isVaccine ? L10n.prscDtlTxtYes : L10n.prscDtlTxtNo,
                        description: L10n.prscDtlMedTxtDrugVaccine
                    )
                    .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedVaccine)
                }

                if let instructions = viewStore.medication?.manufacturingInstructions {
                    SubTitle(title: instructions, description: L10n.prscDtlMedManufacturingInstructions)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedManufacturingInstructions)
                }

                if let packaging = viewStore.medication?.packaging {
                    SubTitle(title: packaging, description: L10n.prscDtlMedTxtPackaging)
                        .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedPackaging)
                }

                if let dispenseState = viewStore.dispenseState {
                    DispenseDetailView(dispenseDetail: dispenseState)
                }

            }.sectionContainerStyle(.inline)
        }
    }

    struct DispenseDetailView: View {
        let dispenseDetail: MedicationDomain.State.DispenseState
        var body: some View {
            if let expiresOn = dispenseDetail.expiresOn {
                SubTitle(
                    title: expiresOn,
                    description: L10n.prscDtlMedTxtBatchExpiresOn
                )
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedBatchExpiresOn)
            }

            if let lotNumber = dispenseDetail.lotNumber {
                SubTitle(
                    title: lotNumber,
                    description: L10n.prscDtlMedTxtBatchLotNumber
                )
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedBatchLotNumber)
            }

            if let dosageInstruction = dispenseDetail.dosageInstruction {
                SubTitle(
                    title: dosageInstruction,
                    description: L10n.prscDtlTxtDosageInstructions
                )
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedDosageInstructions)
            }

            if let noteText = dispenseDetail.noteText {
                SubTitle(
                    title: noteText,
                    description: L10n.prscDtlMedTxtNote
                )
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedNote)
            }

            if let quantity = dispenseDetail.quantity?.description {
                SubTitle(
                    title: quantity,
                    description: L10n.prscDtlMedTxtAmount
                )
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedAmount)
            }

            if let whenHandedOver = dispenseDetail.whenHandedOver {
                SubTitle(
                    title: whenHandedOver,
                    description: L10n.prscDtlMedTxtHandedOverDate
                )
                .accessibilityIdentifier(A11y.prescriptionDetails.prscDtlMedHandedOverDate)
            }
        }
    }
}

extension MedicationView {
    struct IngredientView: View {
        let store: Store<MedicationDomain.Destinations.IngredientState, MedicationDomain.Action>

        var body: some View {
            WithViewStore(store) { viewStore in
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
}

extension ErxMedication {
    var displayName: String {
        if let name = name {
            return name
        } else {
            let joinedText = ingredients.compactMap(\.text).joined(separator: ", ")
            guard !joinedText.isEmpty else { return L10n.prscTxtFallbackName.text }
            return joinedText
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
            NavigationView {
                MedicationView(
                    store: .init(
                        initialState: .init(subscribed: ErxTask.Demo.pznMedication),
                        reducer: MedicationDomain()
                    )
                )
            }
            // Freetext
            NavigationView {
                MedicationView(
                    store: .init(
                        initialState: .init(subscribed: ErxTask.Demo.freeTextMedication),
                        reducer: MedicationDomain()
                    )
                )
            }.preferredColorScheme(.dark)

            // Ingredient/Compounding
            NavigationView {
                MedicationView(
                    store: .init(
                        initialState: .init(subscribed: ErxTask.Demo.compoundingMedication),
                        reducer: MedicationDomain()
                    )
                )
            }.preferredColorScheme(.dark)

            // Dispensed Ingredient/Compounding
            NavigationView {
                MedicationView(
                    store: .init(
                        initialState: .init(
                            dispensed: ErxMedicationDispense.Demo.demoMedicationDispense,
                            dateFormatter: UIDateFormatter.previewValue
                        ),
                        reducer: MedicationDomain()
                    )
                )
            }
        }
    }
}
