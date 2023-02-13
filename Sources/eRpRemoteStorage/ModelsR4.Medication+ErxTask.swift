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

import eRpKit
import Foundation
import ModelsR4

extension ModelsR4.Medication {
    var profileType: ErxTask.Medication.ProfileType? {
        guard let profileType = meta?.profile?.first?.value?.url.absoluteString else {
            return nil
        }

        return .init(urlString: profileType)
    }

    var version: Prescription.Version? {
        guard let kbvVersion = meta?.profile?.first?.value?.version else {
            return nil
        }

        return Prescription.Version(rawValue: kbvVersion)
    }

    var drugCategory: ErxTask.Medication.DrugCategory? {
        `extension`?.first {
            $0.url.value?.url.absoluteString == Prescription.Key.Medication.categoryKey
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
            $0.url.value?.url.absoluteString == Prescription.Key.Medication.vaccineKey
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
            $0.url.value?.url.absoluteString == Prescription.Key.Medication.packagingKey
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
            $0.url.value?.url.absoluteString == Prescription.Key.Medication.compoundingInstructionKey
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.string(valueString) = valueX {
                return valueString.value?.string
            }
            return nil
        }
    }

    var medicationText: String? {
        code?.text?.value?.string
    }

    var erxTaskIngredients: [ErxTask.Medication.Ingredient] {
        guard let ingredients = ingredient,
              let version = version else {
            return []
        }

        switch profileType {
        case .ingredient:
            return ingredients.map {
                ErxTask.Medication.Ingredient(
                    text: $0.name,
                    number: $0.wirkstoffNumber,
                    form: $0.form,
                    strength: $0.amount(for: version),
                    strengthFreeText: $0.amountFreetext
                )
            }
        case .compounding:
            return ingredients.map {
                ErxTask.Medication.Ingredient(
                    text: $0.name,
                    number: $0.pznNumber,
                    form: $0.form,
                    strength: $0.amount(for: version),
                    strengthFreeText: $0.amountFreetext
                )
            }
        default:
            return []
        }
    }

    var dosageForm: String? {
        switch profileType {
        case .pzn:
            return form?.coding?.first {
                $0.system?.value?.url.absoluteString == Prescription.Key.dosageFormKey
            }?.code?.value?.string
        default:
            return form?.text?.value?.string
        }
    }

    var decimalAmount: Decimal? {
        guard let numerator = amount?.numerator?.value?.value?.decimal,
              let denominator = amount?.denominator?.value?.value?.decimal else { return nil }
        return numerator / denominator
    }

    func amountRatio(for version: Prescription.Version) -> ErxTask.Ratio? {
        createRatio(for: amount, for: version)
    }

    var dose: String? {
        `extension`?.first {
            $0.url.value?.url.absoluteString == Prescription.Key.medicationDoesKey
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

    var pzn: String? {
        code?.coding?.first {
            $0.system?.value?.url.absoluteString == Prescription.Key.pznKey
        }?.code?.value?.string
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
                $0.system?.value?.url.absoluteString == Prescription.Key.Medication.wirkstoffNumberKey
            }?.code?.value?.string
        }

        return nil
    }

    var pznNumber: String? {
        if case let MedicationIngredient.ItemX.codeableConcept(concept) = item {
            return concept.coding?.first {
                $0.system?.value?.url.absoluteString == Prescription.Key.pznKey
            }?.code?.value?.string
        }

        return nil
    }

    var form: String? {
        `extension`?.first {
            $0.url.value?.url.absoluteString == Prescription.Key.Medication.ingredientFormKey
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
            $0.url.value?.url.absoluteString == Prescription.Key.Medication.ingredientAmountKey
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.string(valueString) = valueX {
                return valueString.value?.string
            }
            return nil
        }
    }

    func amount(for version: Prescription.Version) -> ErxTask.Ratio? {
        createRatio(for: strength, for: version)
    }
}

private func createRatio(for amount: Ratio?, for version: Prescription.Version) -> ErxTask.Ratio? {
    guard let unit = amount?.numerator?.unit?.value?.string else {
        return nil
    }

    var denominator: ErxTask.Quantity?
    if let denominatorValue = amount?.denominator?.value?.value?.decimal.description {
        denominator = ErxTask.Quantity(
            value: denominatorValue,
            unit: amount?.denominator?.unit?.value?.string
        )
    }

    switch version {
    case .v1_0_2:
        guard let value = amount?.numerator?.value?.value?.decimal.description else {
            return nil
        }

        return ErxTask.Ratio(
            numerator: ErxTask.Quantity(value: value, unit: unit),
            denominator: denominator
        )
    case .v1_1_0:
        if let value = amount?.numerator?.value?.value?.decimal.description {
            return ErxTask.Ratio(
                numerator: ErxTask.Quantity(value: value, unit: unit),
                denominator: denominator
            )
        } else {
            if let numeratorExtension = amount?.numerator?.extension {
                return numeratorExtension.first {
                    $0.url.value?.url.absoluteString == Prescription.Key.Medication.packagingSizeKey
                }
                .flatMap {
                    if let valueX = $0.value,
                       case let Extension.ValueX.string(valueString) = valueX,
                       let value = valueString.value?.string {
                        return ErxTask.Ratio(
                            numerator: ErxTask.Quantity(value: value, unit: unit),
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

extension ErxTask.Medication.ProfileType {
    init(urlString: String) {
        switch urlString {
        case Prescription.Key.Medication.PZNKey: self = .pzn
        case Prescription.Key.Medication.compoundingKey: self = .compounding
        case Prescription.Key.Medication.ingredientKey: self = .ingredient
        case Prescription.Key.Medication.freeTextKey: self = .freeText
        default:
            self = .unknown
        }
    }
}

extension ErxTask.Medication.DrugCategory {
    init(value: String) {
        switch value {
        case "00": self = .avm
        case "01": self = .btm
        case "02": self = .amvv
        default:
            self = .unknown
        }
    }
}
