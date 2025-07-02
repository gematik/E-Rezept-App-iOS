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

// Note: All values should be implemented in a loosely manner so that
// medications from any profile type can be parsed. This is relevant because medications
// are created during MedicationDispense by the DAV and they are not restricted
// to use the KBV profiles
extension ModelsR4.Medication {
    var profileType: ErxMedication.ProfileType? {
        guard let profileType = meta?.profile?.first?.value?.url.absoluteString else {
            return nil
        }

        return .init(urlString: profileType)
    }

    var version: ErpPrescription.Version? {
        guard let kbvVersion = meta?.profile?.first?.value?.version else {
            return nil
        }

        return ErpPrescription.Version(rawValue: kbvVersion)
    }

    // TODO: Consider grouping medicationText and pzn in `Code` and also fill code //swiftlint:disable:this todo
    // for other profile types. The decision taken here, to only display pzn should be
    // done in the view model
    var medicationText: String? {
        code?.text?.value?.string
    }

    var pzn: String? {
        code?.coding?.first {
            $0.system?.value?.url.absoluteString == ErpPrescription.Key.pznKey
        }?.code?.value?.string
    }

    var drugCategory: ErxMedication.DrugCategory? {
        `extension`?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.Medication.categoryKey
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.coding(valueCoding) = valueX,
               let key = valueCoding.code?.value?.string {
                return .init(value: key)
            }
            return nil
        }
    }

    var isVaccine: Bool {
        `extension`?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.Medication.vaccineKey
        }
        .map {
            if let valueX = $0.value,
               case Extension.ValueX.boolean(true) = valueX {
                return true
            }
            return false
        } ?? false
    }

    var packaging: String? {
        `extension`?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.Medication.packagingKey
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.string(valueString) = valueX {
                return valueString.value?.string
            }
            return nil
        }
    }

    var compoundingInstruction: String? {
        `extension`?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.Medication.compoundingInstructionKey
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.string(valueString) = valueX {
                return valueString.value?.string
            }
            return nil
        }
    }

    var erxTaskIngredients: [ErxMedication.Ingredient] {
        guard let ingredients = ingredient else {
            return []
        }

        switch profileType {
        case .ingredient:
            return ingredients.map {
                ErxMedication.Ingredient(
                    text: $0.name,
                    number: $0.wirkstoffNumber,
                    form: $0.form,
                    strength: $0.amount(for: version),
                    strengthFreeText: $0.amountFreetext
                )
            }
        case .compounding:
            return ingredients.map {
                ErxMedication.Ingredient(
                    text: $0.name,
                    number: $0.pznNumber,
                    form: $0.form,
                    strength: $0.amount(for: version),
                    strengthFreeText: $0.amountFreetext
                )
            }
        default:
            return ingredients.map {
                ErxMedication.Ingredient(
                    text: $0.name,
                    number: $0.number,
                    form: nil,
                    strength: $0.amount(for: nil),
                    strengthFreeText: nil
                )
            }
        }
    }

    var dosageForm: String? {
        switch profileType {
        case .pzn:
            return form?.coding?.first {
                $0.system?.value?.url.absoluteString == ErpPrescription.Key.dosageFormKey
            }?.code?.value?.string
        default:
            return form?.text?.value?.string
        }
    }

    var medicationAmount: ErxMedication.Ratio? {
        createRatio(for: amount, for: version)
    }

    func amountRatio(for version: ErpPrescription.Version) -> ErxMedication.Ratio? {
        createRatio(for: amount, for: version)
    }

    var normSizeCode: String? {
        `extension`?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.medicationNormSizeCodeKey
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.code(code) = valueX,
               let key = code.value?.string {
                return key
            }
            return nil
        }
    }

    var erxTaskBatch: ErxMedication.Batch? {
        guard lot != nil || expiresOn != nil else {
            return nil
        }
        return .init(
            lotNumber: lot,
            expiresOn: expiresOn
        )
    }

    var lot: String? {
        batch?.lotNumber?.value?.string
    }

    var expiresOn: String? {
        batch?.expirationDate?.value?.description
    }
}

extension ModelsR4.MedicationIngredient {
    var name: String? {
        if case let MedicationIngredient.ItemX.codeableConcept(concept) = item {
            return concept.text?.value?.string
        }

        return nil
    }

    var wirkstoffNumber: String? {
        if case let MedicationIngredient.ItemX.codeableConcept(concept) = item {
            return concept.coding?.first {
                $0.system?.value?.url.absoluteString == ErpPrescription.Key.Medication.activeIngredientNumberKey
            }?.code?.value?.string
        }

        return nil
    }

    var pznNumber: String? {
        if case let MedicationIngredient.ItemX.codeableConcept(concept) = item {
            return concept.coding?.first {
                $0.system?.value?.url.absoluteString == ErpPrescription.Key.pznKey
            }?.code?.value?.string
        }

        return nil
    }

    var number: String? {
        if case let MedicationIngredient.ItemX.codeableConcept(concept) = item {
            return concept.coding?.first?.code?.value?.string
        }

        return nil
    }

    var form: String? {
        `extension`?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.Medication.ingredientFormKey
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.string(valueString) = valueX {
                return valueString.value?.string
            }
            return nil
        }
    }

    var amountFreetext: String? {
        strength?.extension?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.Medication.ingredientAmountKey
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.string(valueString) = valueX {
                return valueString.value?.string
            }
            return nil
        }
    }

    func amount(for version: ErpPrescription.Version?)
        -> ErxMedication.Ratio? {
        createRatio(for: strength, for: version)
    }
}

private func createRatio(for amount: Ratio?, for version: ErpPrescription.Version?) -> ErxMedication.Ratio? {
    var denominator: ErxMedication.Quantity?
    if let denominatorValue = amount?.denominator?.value?.value?.decimal.description {
        denominator = ErxMedication.Quantity(
            value: denominatorValue,
            unit: amount?.denominator?.unit?.value?.string
        )
    }
    let numeratorValue = amount?.numerator?.value?.value?.decimal.description
    let numeratorUnit = amount?.numerator?.unit?.value?.string

    switch version {
    case .none, .v1_0_2:
        guard let value = numeratorValue else { return nil }

        return ErxMedication.Ratio(
            numerator: ErxMedication.Quantity(value: value, unit: numeratorUnit),
            denominator: denominator
        )
    case .v1_1_0:
        if let value = numeratorValue {
            return ErxMedication.Ratio(
                numerator: ErxMedication.Quantity(value: value, unit: numeratorUnit),
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
                        return ErxMedication.Ratio(
                            numerator: ErxMedication.Quantity(value: value, unit: numeratorUnit),
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

extension ErxMedication.ProfileType {
    init(urlString: String) {
        switch urlString {
        case ErpPrescription.Key.Medication.medicationTypePZNKey: self = .pzn
        case ErpPrescription.Key.Medication.medicationTypeCompoundingKey: self = .compounding
        case ErpPrescription.Key.Medication.medicationTypeIngredientKey: self = .ingredient
        case ErpPrescription.Key.Medication.medicationTypeFreeTextKey: self = .freeText
        default:
            self = .unknown
        }
    }
}

extension ErxMedication.DrugCategory {
    init(value: String) {
        switch value {
        case "00": self = .avm
        case "01": self = .btm
        case "02": self = .amvv
        case "03": self = .other
        default:
            self = .unknown
        }
    }
}
