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

import eRpKit
import Foundation
import ModelsR4

extension ModelsR4.MedicationRequest {
    // emergencyServiceFee
    var noctuFeeWaiver: Bool {
        `extension`?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.MedicationRequest.noctuFeeWaiverKey
        }
        .map {
            if let valueX = $0.value,
               case Extension.ValueX.boolean(true) = valueX {
                return true
            }
            return false
        } ?? false
    }

    var bvg: Bool {
        `extension`?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.MedicationRequest.bvg
        }
        .map {
            if let valueX = $0.value,
               case Extension.ValueX.boolean(true) = valueX {
                return true
            }
            return false
        } ?? false
    }

    var accidentInfo: AccidentInfo? {
        guard let accident = `extension`?.first(where: { identifier in
            ErpPrescription.Key.MedicationRequest.accidentInfoKey
                .contains { $0.value == identifier.url.value?.url.absoluteString }
        }) else {
            return nil
        }

        let identifier: String? = accident.extension?.first { identifier in
            ErpPrescription.Key.MedicationRequest.accidentTypeKey
                .contains { $0.value == identifier.url.value?.url.absoluteString }
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.coding(coding) = valueX {
                return coding.code?.value?.string
            }
            return nil
        }

        let place: String? = accident.extension?.first { identifier in
            ErpPrescription.Key.MedicationRequest.accidentPlaceKey
                .contains { $0.value == identifier.url.value?.url.absoluteString }
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.string(str) = valueX {
                return str.value?.string
            }
            return nil
        }

        let date: String? = accident.extension?.first { identifier in
            ErpPrescription.Key.MedicationRequest.accidentDateKey
                .contains { $0.value == identifier.url.value?.url.absoluteString }
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.date(date) = valueX,
               let dateString = date.value?.description {
                return dateString
            }
            return nil
        }

        var accidentType: AccidentInfo.AccidentType?
        if let type = identifier {
            accidentType = .init(type: type)
        }

        return AccidentInfo(
            type: accidentType,
            workPlaceIdentifier: place,
            date: date
        )
    }

    var multiplePrescription: MultiplePrescription? {
        guard let prescriptionInfo = `extension`?.first(where: {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.MedicationRequest.multiplePrescriptionKey
        }) else {
            return nil
        }

        let mark: Bool = prescriptionInfo.extension?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.MedicationRequest.multiplePrescriptionMark
        }
        .map {
            if let valueX = $0.value,
               case Extension.ValueX.boolean(true) = valueX {
                return true
            }
            return false
        } ?? false

        let ratio: Ratio? = prescriptionInfo.extension?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.MedicationRequest.multiplePrescriptionNumber
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.ratio(ratio) = valueX {
                return ratio
            }
            return nil
        }

        let numbering: Decimal? = ratio?.numerator?.value?.value?.decimal
        let totalNumber: Decimal? = ratio?.denominator?.value?.value?.decimal

        let period: Period? = prescriptionInfo.extension?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.MedicationRequest.multiplePrescriptionPeriod
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.period(period) = valueX {
                return period
            }
            return nil
        }

        let startPeriod: String? = period?.start?.value?.date.description
        let endPeriod: String? = period?.end?.value?.date.description

        return MultiplePrescription(
            mark: mark,
            numbering: numbering,
            totalNumber: totalNumber,
            startPeriod: startPeriod,
            endPeriod: endPeriod
        )
    }

    var kbvDosageInstruction: String? {
        guard let instruction = dosageInstruction?.first else {
            return nil
        }

        let hasInstructions = instruction.extension?
            .first {
                $0.url.value?.url.absoluteString == ErpPrescription.Key.MedicationRequest.dosageInstructionFlagKey
            }
            .flatMap {
                if let valueX = $0.value,
                   case Extension.ValueX.boolean(true) = valueX {
                    return true
                }
                return false
            }

        if hasInstructions == false {
            return ErpPrescription.Key.MedicationRequest.dosageInstructionDj
        } else {
            return instruction.text?.value?.string
        }
    }

    var substitutionAllowed: Bool {
        if case .boolean(booleanLiteral: true) = substitution?.allowed {
            return true
        }
        return false
    }

    var coPaymentStatus: ErxTask.CoPaymentStatus? {
        `extension`?.first { identifier in
            ErpPrescription.Key.MedicationRequest.statusCoPaymentKey
                .contains { $0.value == identifier.url.value?.url.absoluteString }
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.coding(valueCoding) = valueX,
               let value = valueCoding.code?.value?.string {
                return ErxTask.CoPaymentStatus(rawValue: value)
            }
            return nil
        }
    }

    var erxTaskQuantity: ErxMedication.Quantity? {
        guard let valueString = dispenseRequest?.quantity?.value?.value?.decimal.description else {
            return nil
        }

        if dispenseRequest?.quantity?.code?.value?.string == "{Package}" {
            return .init(value: valueString, unit: "{Package}")
        } else {
            return .init(value: valueString, unit: dispenseRequest?.quantity?.unit?.value?.string)
        }
    }
}

extension AccidentInfo.AccidentType {
    init(type: String) {
        switch type {
        case "1": self = .accident
        case "2": self = .workAccident
        case "4": self = .workRelatedDisease
        default:
            self = .unknown
        }
    }
}
