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

import eRpKit
import Foundation
import ModelsR4

extension ErxEpaMedication {
    init(medication: ModelsR4.Medication) {
        self.init(
            epaMedicationType: medication.epaMedicationType,
            drugCategory: medication.epaMedicationDrugCategory,
            code: medication.code?.parseEpaMedicationCodeCodableConcept,
            status: medication.epaMedicationStatus,
            isVaccine: medication.epaMedicationIsVaccine,
            amount: medication.epaMedicationAmount,
            form: medication.epaMedicationForm,
            normSizeCode: medication.normSizeCode,
            batch: medication.erxEpaMedicationTaskBatch,
            packaging: medication.packaging,
            manufacturingInstructions: medication.compoundingInstruction,
            ingredients: medication.erxEpaMedicationIngredients
        )
    }
}

extension ModelsR4.Medication {
    var epaMedicationType: EpaMedicationType? {
        if let typeExtension = extensions(for: EpaMedication.Key.typeExtensionKey).first,
           let valueX = typeExtension.value,
           case let Extension.ValueX.coding(valueCoding) = valueX,
           let key = valueCoding.code?.value?.string {
            return EpaMedicationType(rawValue: key)
        } else {
            return nil
        }
    }

    var epaMedicationStatus: EpaMedicationStatus? {
        guard let status = status?.value?.rawValue else {
            return nil
        }
        return EpaMedicationStatus(rawValue: status)
    }

    var epaMedicationIsVaccine: Bool? {
        extensions(for: EpaMedication.Key.drugCategoryExtensionKey)
            .first
            .map {
                if let valueX = $0.value,
                   case Extension.ValueX.boolean(true) = valueX {
                    return true
                }
                return false
            }
    }

    var epaMedicationDrugCategory: EpaMedicationDrugCategory? {
        extensions(for: EpaMedication.Key.drugCategoryExtensionKey).first
            .flatMap {
                if let valueX = $0.value,
                   case let Extension.ValueX.coding(valueCoding) = valueX,
                   let key = valueCoding.code?.value?.string,
                   let category = EpaMedicationDrugCategory(rawValue: key) {
                    return category
                }
                return nil
            }
    }

    var epaMedicationForm: EpaMedicationFormCodableConcept? {
        guard let form = form else {
            return nil
        }
        let codings: [EpaMedicationCoding<FormCodingSystem>] = form.coding?.compactMap {
            guard
                let systemString = $0.system?.value?.url.absoluteString,
                let system = FormCodingSystem(rawValue: systemString),
                let code = $0.code?.value?.string
            else { return nil }
            return .init(
                system: system,
                version: $0.version?.value?.string,
                code: code,
                display: $0.display?.value?.string,
                userSelected: $0.userSelected?.value?.bool
            )
        } ?? []
        return EpaMedicationFormCodableConcept(
            codings: codings,
            text: form.text?.value?.string
        )
    }

    var epaMedicationAmount: EpaMedicationRatio? {
        createEpaMedicationRatio(for: amount)
    }

    var erxEpaMedicationTaskBatch: EpaMedicationBatch? {
        guard lot != nil || expiresOn != nil else {
            return nil
        }
        return .init(
            lotNumber: lot,
            expiresOn: expiresOn
        )
    }

    var erxEpaMedicationIngredients: [EpaMedicationIngredient] {
        guard let ingredients = ingredient
        else { return [] }

        return ingredients.compactMap { medicationIngredient in
            let item: EpaMedicationIngredient.Item
            let itemX = medicationIngredient.item
            switch itemX {
            case let .codeableConcept(codeableConcept):
                item = .codableConcept(codeableConcept.parseEpaMedicationCodeCodableConcept)
            case let .reference(reference):
                guard let referenceString: ModelsR4.FHIRPrimitive<FHIRString> = reference.reference,
                      let parseContainedIngredientItem = parseContainedIngredientItemBy(reference: referenceString)
                else { return nil }
                item = parseContainedIngredientItem
            }

            return EpaMedicationIngredient(
                item: item,
                isActive: medicationIngredient.isActive?.value?.bool,
                strength: createEpaMedicationIngredientStrength(for: medicationIngredient.strength),
                darreichungsForm: medicationIngredient.darreichungsForm
            )
        }
    }
}

extension ModelsR4.CodeableConcept {
    var parseEpaMedicationCodeCodableConcept: EpaMedicationCodeCodableConcept {
        let codings: [EpaMedicationCoding<CodeCodingSystem>] = coding?.compactMap {
            guard
                let systemString = $0.system?.value?.url.absoluteString,
                let system = CodeCodingSystem(rawValue: systemString),
                let code = $0.code?.value?.string
            else { return nil }
            return .init(
                system: system,
                version: $0.version?.value?.string,
                code: code,
                display: $0.display?.value?.string,
                userSelected: $0.userSelected?.value?.bool
            )
        } ?? []
        return EpaMedicationCodableConcept(
            codings: codings,
            text: text?.value?.string
        )
    }
}

extension ModelsR4.Medication {
    func parseContainedIngredientItemBy(
        reference: ModelsR4.FHIRPrimitive<FHIRString>
    ) -> EpaMedicationIngredient.Item? {
        guard let contained else { return nil }

        let medications = contained.compactMap { containedElement in
            containedElement.get(if: ModelsR4.Medication.self)
        }
        guard let referencedMedication: ModelsR4.Medication = medications.first(
            where: { medication in
                medication.id == reference.droppingLeadingNumberSign
            }
        )
        else { return nil }

        if referencedMedication.meta?.profile?.first?.value?.url.absoluteString == EpaMedication.Key.pznIngredientKey,
           let epaMedicationPznIngredient = referencedMedication.parseEpaMedicationPznIngredient {
            return .epaMedication(epaMedicationPznIngredient)
        } else if referencedMedication.meta?.profile?.first?.value?.url.absoluteString ==
            EpaMedication.Key.pharmaceuticalProductKey,
            let epaMedicationPharmaceuticalProduct = referencedMedication.parseEpaMedicationPharmaceuticalProduct {
            return .epaMedication(epaMedicationPharmaceuticalProduct)
        } else {
            return nil
        }
    }

    var parseEpaMedicationPznIngredient: ErxEpaMedication? {
        ErxEpaMedication(medication: self)
    }

    var parseEpaMedicationPharmaceuticalProduct: ErxEpaMedication? {
        ErxEpaMedication(medication: self)
    }

    func createEpaMedicationIngredientStrength(for strength: ModelsR4.Ratio?) -> EpaMedicationIngredient.Strength? {
        guard let ratio: EpaMedicationRatio = createEpaMedicationRatio(for: strength)
        else { return nil }
        let amountText: String? = strength?.extensions(
            for: EpaMedication.Key.ingredientAmountExtensionKey
        ).first?.value?.stringOrNil

        return EpaMedicationIngredient.Strength(ratio: ratio, amountText: amountText)
    }

    func createEpaMedicationRatio(for amount: Ratio?) -> EpaMedicationRatio? {
        var denominator: EpaMedicationRatio.Quantity?
        if let denominatorValue = amount?.denominator?.value?.value?.decimal.description {
            denominator = EpaMedicationRatio.Quantity(
                value: denominatorValue,
                unit: amount?.denominator?.unit?.value?.string,
                system: amount?.denominator?.system?.value?.url.absoluteString,
                code: amount?.denominator?.code?.value?.string
            )
        }
        let numeratorValue = amount?.numerator?.value?.value?.decimal.description
        let numeratorUnit = amount?.numerator?.unit?.value?.string

        if let value = numeratorValue {
            let numerator = EpaMedicationRatio.Quantity(
                value: value,
                unit: numeratorUnit,
                system: amount?.numerator?.system?.value?.url.absoluteString,
                code: amount?.numerator?.code?.value?.string
            )
            return EpaMedicationRatio(
                numerator: numerator,
                denominator: denominator
            )
        } else {
            if let numeratorExtension = amount?.numerator?.extension {
                return numeratorExtension.first {
                    $0.url.value?.url.absoluteString == ErpPrescription.Key.Medication.packagingSizeKey
                }
                .flatMap {
                    if let valueX = $0.value,
                       case let Extension.ValueX.string(valueString) = valueX,
                       let value = valueString.value?.string {
                        return EpaMedicationRatio(
                            numerator: EpaMedicationRatio.Quantity(value: value, unit: numeratorUnit),
                            denominator: denominator
                        )
                    }
                    return nil
                }
            }

            return nil
        }
    }
}

extension ModelsR4.MedicationIngredient {
    var darreichungsForm: String? {
        extensions(for: EpaMedication.Key.ingredientDarreichungsformExtensionKey).first?.value?.stringOrNil
    }
}

extension ModelsR4.FHIRPrimitive where PrimitiveType == ModelsR4.FHIRString {
    var droppingLeadingNumberSign: Self {
        guard let stringValue = value?.string, stringValue.starts(with: "#") else {
            return self
        }

        return FHIRPrimitive(FHIRString(String(stringValue.dropFirst())))
    }
}
