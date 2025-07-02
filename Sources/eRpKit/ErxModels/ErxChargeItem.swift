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

import Foundation

/// The resource ChargeItem describes the provision of healthcare provider products for a certain patient,
/// therefore referring not only to the product, but containing in addition details of the provision,
/// like date, time, amounts and participating organizations and persons.
/// Main Usage of the ChargeItem is to enable the billing process and internal cost allocation.
public struct ErxChargeItem: Identifiable, Hashable, Codable {
    /// ErxChargeItem default initializer
    public init(
        identifier: String,
        fhirData: Data,
        taskId: String? = nil,
        enteredDate: String? = nil,
        accessCode: String? = nil,
        medication: ErxMedication? = nil,
        medicationRequest: ErxMedicationRequest = ErxMedicationRequest(quantity: nil),
        patient: ErxPatient? = nil,
        practitioner: ErxPractitioner? = nil,
        organization: ErxOrganization? = nil,
        pharmacy: DavOrganization? = nil,
        invoice: DavInvoice? = nil,
        medicationDispense: DavMedicationDispense? = nil,
        prescriptionSignature: ErxSignature? = nil,
        receiptSignature: ErxSignature? = nil,
        dispenseSignature: ErxSignature? = nil,
        isRead: Bool = false
    ) {
        self.identifier = identifier
        self.taskId = taskId
        self.fhirData = fhirData
        self.enteredDate = enteredDate
        self.accessCode = accessCode
        self.medication = medication
        self.medicationRequest = medicationRequest
        self.patient = patient
        self.practitioner = practitioner
        self.organization = organization
        self.pharmacy = pharmacy
        self.invoice = invoice
        self.medicationDispense = medicationDispense
        self.prescriptionSignature = prescriptionSignature
        self.receiptSignature = receiptSignature
        self.dispenseSignature = dispenseSignature
        self.isRead = isRead
    }

    // MARK: Meta Information

    /// Id of the consent
    public var id: String { identifier }
    /// Identifier of the charge item
    public let identifier: String
    /// Complete FHIR bundle as json encoded data
    public let fhirData: Data
    /// TaskId of the actual prescription
    public let taskId: String?
    /// Date the charge item was entered
    public let enteredDate: String?
    /// Access code authorising for the charge item
    public let accessCode: String?
    /// Indicates if the message about the ChargeItem in the order section has been opened by the user
    public var isRead: Bool

    // MARK: KBV profiled FHIR resources

    /// The prescribed medication
    public let medication: ErxMedication?
    /// Everything contained in a MedicationRequest resource
    public let medicationRequest: ErxMedicationRequest
    /// Patient for whom the prescription is issued
    public let patient: ErxPatient?
    /// Practitioner who issued the prescription
    public let practitioner: ErxPractitioner?
    /// Organization that issued the prescription
    public let organization: ErxOrganization?

    // MARK: DAV profiled FHIR resources

    /// Pharmacy that issued the medication
    public let pharmacy: DavOrganization?
    /// Invoice from an Account
    public let invoice: DavInvoice?
    /// actual medication dispenses
    public let medicationDispense: DavMedicationDispense?

    // MARK: Signatures from bundles

    /// Prescription bundle signature
    public let prescriptionSignature: ErxSignature?
    /// Receipt bundle signature
    public let receiptSignature: ErxSignature?
    /// Dispense bundle signature
    public let dispenseSignature: ErxSignature?
}

extension ErxChargeItem {
    /// ChargeItem with sparse data set
    ///
    /// The full ChargeItem information is held as fhirData value
    /// and can be extracted as a `ErxChargeItem`
    public var sparseChargeItem: ErxSparseChargeItem {
        ErxSparseChargeItem(
            identifier: identifier,
            taskId: taskId,
            fhirData: fhirData,
            enteredDate: enteredDate,
            isRead: isRead,
            medication: medication,
            invoice: invoice
        )
    }
}
