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

import Foundation

/// Acts as the intermediate data model from a MedicationDispense resource response
/// and the local store representation
/// MedicationDispenses are created by the pharmacy and can contain different medications from the prescription
/// even when the `substitutionAllowed` flag is false
/// Profile: https://simplifier.net/packages/de.gematik.erezept-workflow.r4/1.2.0/files/721016
public struct ErxMedicationDispense: Hashable, Codable, Sendable {
    /// Default initializer for a MedicationDispense which represent a ModulesR4.MedicationDispense
    public init(
        identifier: String,
        taskId: String,
        insuranceId: String?,
        dosageInstruction: String?,
        telematikId: String?,
        whenHandedOver: String?,
        quantity: ErxMedication.Quantity? = nil,
        noteText: String? = nil,
        medication: ErxMedication?
    ) {
        self.identifier = identifier
        self.taskId = taskId
        self.insuranceId = insuranceId
        self.dosageInstruction = dosageInstruction
        self.telematikId = telematikId
        self.whenHandedOver = whenHandedOver
        self.quantity = quantity
        self.noteText = noteText
        self.medication = medication
    }

    /// unique identifier in each `ErxTask`
    public let identifier: String
    /// id of the related `ErkTask` can also be used as the ID of the MedicationDispense
    public let taskId: String
    /// KVNR of the patient (e.g.: "X110461389")
    public let insuranceId: String?
    /// Indicates how the medication is to be used by the patient.
    /// This is the Information from the pharmacist (which can be different from the medication instructions)
    public let dosageInstruction: String?
    /// Telematik-ID of the pharmacy performing the dispense (performer)
    public let telematikId: String?
    /// Date string representing the actual time of performing the dispense
    public let whenHandedOver: String?
    /// The amount of medication that has been dispensed. Includes unit of measure.
    public let quantity: ErxMedication.Quantity?
    /// Extra information about the dispense that could not be conveyed in the other attributes.
    public let noteText: String?
    /// The contained medication ( most of the time based on the four KBV Medication-Profiles)
    /// - Note: Can contain medications that are not defined by the KBV medication profiles!
    public let medication: ErxMedication?
}
