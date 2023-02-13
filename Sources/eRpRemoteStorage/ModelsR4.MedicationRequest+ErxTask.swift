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

extension ModelsR4.MedicationRequest {
    // emergencyServiceFee
    var noctuFeeWaiver: Bool {
        `extension`?.first {
            $0.url.value?.url.absoluteString == Prescription.Key.MedicationRequest.noctuFeeWaiverKey
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
            $0.url.value?.url.absoluteString == Prescription.Key.MedicationRequest.bvg
        }
        .map {
            if let valueX = $0.value,
               case Extension.ValueX.boolean(true) = valueX {
                return true
            }
            return false
        } ?? false
    }

    var workRelatedAccident: ErxTask.WorkRelatedAccident? {
        guard let accident = `extension`?.first(where: { identifier in
            Prescription.Key.MedicationRequest.workRelatedAccidentKey
                .contains { $0.value == identifier.url.value?.url.absoluteString }
        }) else {
            return nil
        }

        let identifier: String? = accident.extension?.first { identifier in
            Prescription.Key.MedicationRequest.workRelatedAccidentMarkKey
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
            Prescription.Key.MedicationRequest.workRelatedAccidentPlace
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
            Prescription.Key.MedicationRequest.workRelatedAccidentDate
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

        return ErxTask.WorkRelatedAccident(
            mark: identifier,
            workPlaceIdentifier: place,
            date: date
        )
    }

    var multiplePrescription: ErxTask.MultiplePrescription? {
        guard let prescriptionInfo = `extension`?.first(where: {
            $0.url.value?.url.absoluteString == Prescription.Key.MedicationRequest.multiplePrescriptionKey
        }) else {
            return nil
        }

        let mark: Bool = prescriptionInfo.extension?.first {
            $0.url.value?.url.absoluteString == Prescription.Key.MedicationRequest.multiplePrescriptionMark
        }
        .map {
            if let valueX = $0.value,
               case Extension.ValueX.boolean(true) = valueX {
                return true
            }
            return false
        } ?? false

        let ratio: Ratio? = prescriptionInfo.extension?.first {
            $0.url.value?.url.absoluteString == Prescription.Key.MedicationRequest.multiplePrescriptionNumber
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
            $0.url.value?.url.absoluteString == Prescription.Key.MedicationRequest.multiplePrescriptionPeriod
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

        return ErxTask.MultiplePrescription(
            mark: mark,
            numbering: numbering,
            totalNumber: totalNumber,
            startPeriod: startPeriod,
            endPeriod: endPeriod
        )
    }

    var substitutionAllowed: Bool {
        if case .boolean(booleanLiteral: true) = substitution?.allowed {
            return true
        }
        return false
    }

    var coPaymentStatus: ErxTask.CoPaymentStatus? {
        `extension`?.first { identifier in
            Prescription.Key.MedicationRequest.statusCoPaymentKey
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
}
