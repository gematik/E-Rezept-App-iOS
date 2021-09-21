//
//  Copyright (c) 2021 gematik GmbH
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

extension ModelsR4.Bundle {
    /// Parse and extract all found MedicationDispense from `Self`
    ///
    /// - Returns: Array with all found and parsed communications
    /// - Throws: `ModelsR4.Bundle.Error`
    func parseErxTaskMedicationDispenses() throws -> [ErxTask.MedicationDispense] {
        try entry?.compactMap {
            guard let medicationDispense = $0.resource?.get(if: ModelsR4.MedicationDispense.self) else {
                return nil
            }
            return try Self.parse(medicationDispense)
        } ?? []
    }

    static func parse(_ medicationDispense: ModelsR4.MedicationDispense) throws -> ErxTask.MedicationDispense {
        guard let taskId = medicationDispense.taskId else {
            throw Error.parseError("Could not parse task id from medication dispense.")
        }

        guard let insuranceId = medicationDispense.insuranceIdentifier else {
            throw Error.parseError("Could not parse kvnr from medication dispense.")
        }

        guard let productNumber = medicationDispense.medicationPZN else {
            throw Error.parseError("Could not parse pzn number from medication dispense.")
        }

        guard let performerID = medicationDispense.firstPerformerID else {
            throw Error.parseError("Could not parse performerID from medication dispense.")
        }

        guard let handedOverDateString = medicationDispense.handOverDate else {
            throw Error.parseError("Could not parse whenHandedOver from medication dispense.")
        }

        return ErxTask.MedicationDispense(
            taskId: taskId,
            insuranceId: insuranceId,
            pzn: productNumber,
            name: medicationDispense.medicationText,
            dose: medicationDispense.medicationDose,
            dosageForm: medicationDispense.medicationDosageForm,
            dosageInstruction: medicationDispense.firstDosageInstruction,
            amount: medicationDispense.medicationAmount,
            telematikId: performerID,
            whenHandedOver: handedOverDateString
        )
    }
}

extension ModelsR4.MedicationDispense {
    var taskId: String? {
        identifier?.first {
            $0.system?.value?.url.absoluteString == FHIRResponseKeys.prescriptionIdKey
        }?.value?.value?.string
    }

    var insuranceIdentifier: String? {
        guard subject?.identifier?.system?.value?.url.absoluteString == FHIRResponseKeys.kvIDKey else {
            return nil
        }
        return subject?.identifier?.value?.value?.string
    }

    var medication: ModelsR4.Medication? {
        contained?.first { resourceProxy in
            if case ModelsR4.ResourceProxy.medication = resourceProxy {
                return true
            }
            return false
        }?
            .get() as? ModelsR4.Medication
    }

    var medicationPZN: String? {
        medication?.pzn
    }

    var medicationText: String? {
        medication?.medicationText
    }

    var medicationDosageForm: String? {
        medication?.dosageForm
    }

    var medicationDose: String? {
        medication?.dose
    }

    var firstDosageInstruction: String? {
        dosageInstruction?.first?.text?.value?.string
    }

    var medicationAmount: Decimal? {
        medication?.decimalAmount
    }

    var firstPerformerID: String? {
        performer?.first?.actor.identifier?.value?.value?.string
    }

    var handOverDate: String? {
        whenHandedOver?.value?.description
    }
}
