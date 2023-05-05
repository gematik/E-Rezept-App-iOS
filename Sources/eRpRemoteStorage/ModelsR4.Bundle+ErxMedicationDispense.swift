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

extension ModelsR4.Bundle {
    /// Parse and extract all found MedicationDispense from `Self`
    ///
    /// - Returns: Array with all found and parsed communications
    /// - Throws: `ModelsR4.Bundle.Error`
    func parseErxMedicationDispenses() throws -> [ErxMedicationDispense] {
        try entry?.compactMap {
            guard let medicationDispense = $0.resource?.get(if: ModelsR4.MedicationDispense.self) else {
                return nil
            }
            return try Self.parse(medicationDispense)
        } ?? []
    }

    static func parse(_ medicationDispense: ModelsR4.MedicationDispense) throws -> ErxMedicationDispense {
        guard let identifier = medicationDispense.id?.value?.string else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse identifier from medication dispense.")
        }

        guard let taskId = medicationDispense.taskId else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse task id from medication dispense.")
        }

        return .init(
            identifier: identifier,
            taskId: taskId,
            insuranceId: medicationDispense.insuranceIdentifier,
            dosageInstruction: medicationDispense.firstDosageInstruction,
            telematikId: medicationDispense.firstPerformerID,
            whenHandedOver: medicationDispense.handOverDate,
            quantity: medicationDispense.erxTaskQuantity,
            noteText: medicationDispense.noteText,
            medication: medicationDispense.erxTaskMedication
        )
    }
}

extension ModelsR4.MedicationDispense {
    var taskId: String? {
        identifier?.first { identifier in
            Workflow.Key.prescriptionIdKeys.contains { $0.value == identifier.system?.value?.url.absoluteString }
        }?.value?.value?.string
    }

    var insuranceIdentifier: String? {
        guard Workflow.Key.kvIDKeys.contains(
            where: { $0.value == subject?.identifier?.system?.value?.url.absoluteString }
        ) else {
            return nil
        }
        return subject?.identifier?.value?.value?.string
    }

    var firstDosageInstruction: String? {
        dosageInstruction?.first?.text?.value?.string
    }

    var medicationAmount: ErxMedication.Ratio? {
        guard let version = medication?.version else { return nil }
        return medication?.amountRatio(for: version)
    }

    var firstPerformerID: String? {
        performer?.first?.actor.identifier?.value?.value?.string
    }

    var handOverDate: String? {
        whenHandedOver?.value?.description
    }

    var erxTaskQuantity: ErxMedication.Quantity? {
        quantity?.erxTaskQuantity
    }

    var noteText: String? {
        note?.compactMap { $0.text.value?.string }.joined(separator: "\n")
    }

    // MARK: contained Medication

    var medication: ModelsR4.Medication? {
        contained?.first { resourceProxy in
            if case ModelsR4.ResourceProxy.medication = resourceProxy {
                return true
            }
            return false
        }?
            .get() as? ModelsR4.Medication
    }

    var erxTaskMedication: ErxMedication? {
        guard let medication = medication else { return nil }

        return .init(
            name: medication.medicationText,
            profile: medication.profileType,
            drugCategory: medication.drugCategory,
            pzn: medication.pzn,
            isVaccine: medication.isVaccine,
            amount: medication.medicationAmount,
            dosageForm: medication.dosageForm,
            dose: medication.dose,
            batch: medication.erxTaskBatch,
            packaging: medication.packaging,
            manufacturingInstructions: medication.compoundingInstruction,
            ingredients: medication.erxTaskIngredients
        )
    }
}

extension ModelsR4.Quantity {
    var erxTaskQuantity: ErxMedication.Quantity? {
        guard let valueString = value?.value?.decimal.description else {
            return nil
        }

        return .init(value: valueString, unit: unit?.value?.string)
    }
}
