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
            return try parse(medicationDispense)
        } ?? []
    }

    func parse(_ medicationDispense: ModelsR4.MedicationDispense) throws -> ErxMedicationDispense {
        guard let identifier = medicationDispense.id?.value?.string else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse identifier from medication dispense.")
        }

        guard let taskId = medicationDispense.taskId else {
            throw RemoteStorageBundleParsingError.parseError("Could not parse task id from medication dispense.")
        }

        // Beginning with GemWorkflow 1.4 the MedicationDispense's Medication is part of the Bundle
        // (formerly it was contained in the MedicationDispense itself)
        let erxMedication: ErxMedication?
        if
            let medicationDispenseMedication = medicationDispense.erxTaskMedication {
            erxMedication = medicationDispenseMedication
        } else {
            erxMedication = nil
        }

        let erxEpaMedication: ErxEpaMedication?
        if
            let reference = medicationDispense.medicationReference,
            let medication = findMedicationResource(with: reference) {
            erxEpaMedication = ErxEpaMedication(medication: medication)
        } else {
            erxEpaMedication = nil
        }

        let diGaDispense: DiGaDispense? = .init(redeemCode: medicationDispense.redeemCode,
                                                deepLink: medicationDispense.deepLink,
                                                isMissingData: medicationDispense.isMissingData)

        return .init(
            identifier: identifier,
            taskId: taskId,
            insuranceId: medicationDispense.insuranceIdentifier,
            dosageInstruction: medicationDispense.firstDosageInstruction,
            telematikId: medicationDispense.firstPerformerID,
            whenHandedOver: medicationDispense.handOverDate,
            quantity: medicationDispense.erxTaskQuantity,
            noteText: medicationDispense.noteText,
            medication: erxMedication,
            epaMedication: erxEpaMedication,
            diGaDispense: diGaDispense
        )
    }

    func findMedicationResource(with: Reference) -> Medication? {
        guard let reference = with.reference?.value?.string else { return nil }
        // try finding it by identifier
        if
            let medications = entry?.compactMap({ $0.resource?.get(if: Medication.self) }),
            let resource = medications.first(where: { medication in

                guard let medicationId = medication.id?.value?.string else { return false }
                return reference.contains(medicationId)

            }) {
            return resource
        }

        return nil
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

    var containedMedication: ModelsR4.Medication? {
        contained?.first { resourceProxy in
            if case ModelsR4.ResourceProxy.medication = resourceProxy {
                return true
            }
            return false
        }?
            .get() as? ModelsR4.Medication
    }

    var erxTaskMedication: ErxMedication? {
        guard let medication = containedMedication else { return nil }

        return .init(medication: medication)
    }

    // MARK: referenced Medication

    var medicationReference: Reference? {
        switch medication {
        case .codeableConcept: return nil
        case let .reference(reference):
            return reference
        }
    }

    // MARK: DiGa dispense info

    var redeemCode: String? {
        `extension`?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.DeviceRequest.redeemCode
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.string(fhirString) = valueX {
                return fhirString.value?.string
            }
            return nil
        }
    }

    var deepLink: String? {
        `extension`?.first {
            $0.url.value?.url.absoluteString == ErpPrescription.Key.DeviceRequest.deepLink
        }
        .flatMap {
            if let valueX = $0.value,
               case let Extension.ValueX.uri(fhirUrl) = valueX {
                return fhirUrl.value?.url.absoluteString
            }
            return nil
        }
    }

    var isMissingData: Bool? {
        medicationReference?.extension?.first {
            $0.url.value?.url.absoluteString == "http://hl7.org/fhir/StructureDefinition/data-absent-reason"
        }
        .flatMap {
            if let valueX = $0.value,
               case Extension.ValueX.code("asked-declined") = valueX {
                return true
            }
            return false
        }
    }
}

extension ErxMedication {
    init(medication: ModelsR4.Medication) {
        self.init(
            name: medication.medicationText,
            profile: medication.profileType,
            drugCategory: medication.drugCategory,
            pzn: medication.pzn,
            isVaccine: medication.isVaccine,
            amount: medication.medicationAmount,
            dosageForm: medication.dosageForm,
            normSizeCode: medication.normSizeCode,
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
