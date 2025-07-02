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
import Dependencies
import eRpKit
import SwiftUI

@Reducer
struct EpaMedicationDomain {
    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = prescriptionDetail_epa_medication_codable_ingredient
        case codableIngredient(EpaMedicationCodableIngredientDomain)
        // sourcery: AnalyticsScreen = prescriptionDetail_epa_medication_ingredient
        case medicationIngredient(EpaMedicationDomain)
    }

    @ObservableState
    struct State: Equatable {
        let epaMedication: ErxEpaMedication?
        let dispenseState: DispenseState?
        @Presents var destination: Destination.State?

        var displayName: String {
            epaMedication?.displayName ?? L10n.prscTxtFallbackName.text
        }

        init(subscribed: ErxEpaMedication) {
            epaMedication = subscribed
            dispenseState = nil
        }

        init(dispensed: ErxMedicationDispense, dateFormatter: UIDateFormatter) {
            epaMedication = dispensed.epaMedication
            dispenseState = .init(
                lotNumber: epaMedication?.batch?.lotNumber,
                expiresOn: dateFormatter.date(epaMedication?.batch?.expiresOn),
                dosageInstruction: dispensed.dosageInstruction,
                whenHandedOver: dateFormatter.date(dispensed.whenHandedOver),
                quantity: dispensed.quantity,
                noteText: dispensed.noteText
            )
        }

        struct DispenseState: Equatable {
            let lotNumber: String?
            let expiresOn: String?
            let dosageInstruction: String?
            let whenHandedOver: String?
            let quantity: ErxMedication.Quantity?
            let noteText: String?
        }
    }

    enum Action: Equatable {
        case destination(PresentationAction<Destination.Action>)
        case showIngredient(EpaMedicationIngredient)
        case resetNavigation
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .showIngredient(ingredient):
                switch ingredient.item {
                case let .codableConcept(epaMedicationCodableConcept):
                    let ingredientState = EpaMedicationCodableIngredientDomain.State(
                        item: epaMedicationCodableConcept,
                        isActive: ingredient.isActive,
                        strength: ingredient.strength,
                        darreichungsForm: ingredient.darreichungsForm
                    )
                    state.destination = .codableIngredient(ingredientState)
                case let .epaMedication(epaMedication):
                    let ingredientsState = EpaMedicationDomain.State(subscribed: epaMedication)
                    state.destination = .medicationIngredient(ingredientsState)
                }
                return .none
            case .resetNavigation:
                state.destination = nil
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ErxEpaMedication {
    var displayName: String? {
        if let name = name {
            return name
        } else {
            let joinedText = ingredients.compactMap(\.name).joined(separator: ", ")
            guard !joinedText.isEmpty else { return nil }
            return joinedText
        }
    }

    var localizedDosageForm: String? {
        if let kbvCoding = form?.codings.first(where: { $0.system == .kbvDarreichungsform }) {
            guard let localizedStringKey = KBVMappingKeys.dosageFormMappingKeys[kbvCoding.code.lowercased()]

            else { return kbvCoding.code }
            return NSLocalizedString(localizedStringKey, bundle: .module, comment: "")
        }

        return form?.text
    }
}

extension EpaMedicationIngredient {
    var name: String? {
        switch item {
        case let .codableConcept(codableConcept):
            return codableConcept.name
        case let .epaMedication(epaMedication):
            return epaMedication.name
        }
    }

    var localizedForm: String? {
        guard let dosageFormKey = darreichungsForm,
              let localizedStringKey = KBVMappingKeys.dosageFormMappingKeys[dosageFormKey.lowercased()] else {
            return darreichungsForm
        }
        return NSLocalizedString(localizedStringKey, bundle: .module, comment: "")
    }
}

extension EpaMedicationCodeCodableConcept {
    var name: String {
        displayName ?? L10n.prscFdTxtNa.text
    }
}

extension EpaMedicationDomain {
    enum Dummies {
        static let state: EpaMedicationDomain.State = .init(
            subscribed: ErxEpaMedication.Dummies.simpleMedication
        )
    }
}

extension ErxEpaMedication {
    enum Dummies { // swiftlint:disable:this type_body_length
        static let simpleMedication: ErxEpaMedication = .init(
            epaMedicationType: nil,
            drugCategory: nil,
            code: EpaMedicationCodeCodableConcept(
                codings: [
                    EpaMedicationCoding<CodeCodingSystem>(
                        system: .pzn,
                        version: nil,
                        code: "06313728",
                        display: nil,
                        userSelected: nil
                    ),
                ],
                text: "Simple pill"
            ),
            status: nil,
            isVaccine: false,
            amount: nil,
            form: nil,
            normSizeCode: nil,
            batch: .init(lotNumber: "123823423", expiresOn: nil),
            packaging: nil,
            manufacturingInstructions: nil,
            ingredients: []
        )

        // Extemporaneous Preparation( Kombipackung)
        static let extemporaneousPreparation: ErxEpaMedication = .init(
            epaMedicationType: .extemporaneousPreparation,
            drugCategory: .avm,
            code: .init(
                codings: [],
                text: "Hydrocortison-Dexpanthenol-Salbe"
            ),
            status: nil,
            isVaccine: false,
            amount: .init(
                numerator: .init(value: "20", unit: "ml"),
                denominator: .init(value: "1")
            ),
            form: .init(
                codings: [.init(system: .kbvDarreichungsform, code: "SAL", display: nil)],
                text: nil
            ),
            normSizeCode: nil,
            batch: nil,
            packaging: nil,
            manufacturingInstructions: nil,
            ingredients: [
                EpaMedicationIngredient(
                    item: EpaMedicationIngredient.Item.epaMedication(
                        ErxEpaMedication(
                            epaMedicationType: .medicinalProductPackage,
                            drugCategory: nil,
                            code: EpaMedicationCodeCodableConcept(
                                codings: [.init(
                                    system: .pzn,
                                    code: "03424249",
                                    display: "Hydrocortison 1% Creme"
                                )],
                                text: nil
                            ),
                            isVaccine: nil,
                            amount: nil,
                            form: nil,
                            normSizeCode: nil,
                            batch: .init(
                                lotNumber: "56498416854",
                                expiresOn: nil
                            ),
                            packaging: nil,
                            manufacturingInstructions: nil,
                            ingredients: []
                        )
                    ),
                    isActive: true,
                    strength: .init(
                        ratio: .init(
                            numerator: .init(
                                value: "50",
                                system: "http://unitsofmeasure.org",
                                code: "g"
                            ),
                            denominator: .init(
                                value: "100",
                                system: "http://unitsofmeasure.org",
                                code: "g"
                            )
                        ),
                        amountText: nil
                    ),
                    darreichungsForm: nil
                ),
                EpaMedicationIngredient(
                    item: EpaMedicationIngredient.Item.epaMedication(
                        ErxEpaMedication(
                            epaMedicationType: .medicinalProductPackage,
                            drugCategory: nil,
                            code: EpaMedicationCodeCodableConcept(
                                codings: [.init(
                                    system: .pzn,
                                    code: "16667195",
                                    display: "Dexpanthenol 5% Creme"
                                )],
                                text: nil
                            ),
                            isVaccine: nil,
                            amount: nil,
                            form: nil,
                            normSizeCode: nil,
                            batch: .init(
                                lotNumber: "0132456",
                                expiresOn: nil
                            ),
                            packaging: nil,
                            manufacturingInstructions: nil,
                            ingredients: []
                        )
                    ),
                    isActive: true,
                    strength: .init(
                        ratio: .init(
                            numerator: .init(
                                value: "50",
                                system: "http://unitsofmeasure.org",
                                code: "g"
                            ),
                            denominator: .init(
                                value: "100",
                                system: "http://unitsofmeasure.org",
                                code: "g"
                            )
                        ),
                        amountText: nil
                    ),
                    darreichungsForm: nil
                ),
            ]
        )

        // Rezeptur
        static let medicinalProductPackage: ErxEpaMedication = .init(
            epaMedicationType: .medicinalProductPackage,
            drugCategory: .avm,
            code: nil,
            status: .active,
            isVaccine: false,
            amount: nil,
            form: .init(
                codings: [.init(system: .kbvDarreichungsform, code: "KPG", display: nil)],
                text: nil
            ),
            normSizeCode: nil,
            batch: nil,
            packaging: nil,
            manufacturingInstructions: nil,
            ingredients: [
                EpaMedicationIngredient(
                    item: EpaMedicationIngredient.Item.epaMedication(
                        ErxEpaMedication(
                            epaMedicationType: .pharmaceuticalBiologicProduct,
                            drugCategory: nil,
                            code: EpaMedicationCodeCodableConcept(
                                codings: [.init(
                                    system: .productKey,
                                    code: "01746517-2",
                                    display: "Nasenspray, Lösung"
                                )],
                                text: nil
                            ),
                            isVaccine: nil,
                            amount: nil,
                            form: nil,
                            normSizeCode: nil,
                            batch: nil,
                            packaging: nil,
                            manufacturingInstructions: nil,
                            ingredients: [
                                EpaMedicationIngredient(
                                    item: .codableConcept(
                                        EpaMedicationCodeCodableConcept(
                                            codings: [
                                                EpaMedicationCoding<CodeCodingSystem>(
                                                    system: .atcDe,
                                                    code: "R01AC01",
                                                    display: "Natriumcromoglicat"
                                                ),
                                            ],
                                            text: nil
                                        )
                                    ),
                                    isActive: nil,
                                    strength: .init(
                                        ratio: .init(
                                            numerator: .init(value: "2.8", unit: "mg"),
                                            denominator: .init(value: "1", unit: "Sprühstoß")
                                        ),
                                        amountText: nil
                                    ),
                                    darreichungsForm: nil
                                ),
                            ]
                        )
                    )
                ),
                EpaMedicationIngredient(
                    item: EpaMedicationIngredient.Item.epaMedication(
                        ErxEpaMedication(
                            epaMedicationType: .pharmaceuticalBiologicProduct,
                            drugCategory: nil,
                            code: EpaMedicationCodableConcept(
                                codings: [
                                    EpaMedicationCoding<CodeCodingSystem>(
                                        system: .productKey,
                                        code: "01746517-1",
                                        display: "Augentropfen"
                                    ),
                                ],
                                text: nil
                            ),
                            isVaccine: nil,
                            amount: nil,
                            form: nil,
                            normSizeCode: nil,
                            batch: nil,
                            packaging: nil,
                            manufacturingInstructions: nil,
                            ingredients: [
                                EpaMedicationIngredient(
                                    item: .codableConcept(
                                        EpaMedicationCodableConcept(
                                            codings: [
                                                EpaMedicationCoding<CodeCodingSystem>(
                                                    system: .atcDe,
                                                    code: "R01AC01",
                                                    display: "Natriumcromoglicat"
                                                ),
                                            ],
                                            text: nil
                                        )
                                    ),
                                    isActive: nil,
                                    strength: .init(
                                        ratio: .init(
                                            numerator: .init(value: "20", unit: "mg"),
                                            denominator: .init(value: "1", unit: "ml")
                                        ),
                                        amountText: nil
                                    ),
                                    darreichungsForm: nil
                                ),
                            ]
                        )
                    )
                ),
            ]
        )
    }
}
