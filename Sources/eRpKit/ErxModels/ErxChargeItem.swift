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

import Foundation

/// The resource ChargeItem describes the provision of healthcare provider products for a certain patient,
/// therefore referring not only to the product, but containing in addition details of the provision,
/// like date, time, amounts and participating organizations and persons.
/// Main Usage of the ChargeItem is to enable the billing process and internal cost allocation.
public struct ErxChargeItem: Identifiable, Hashable {
    /// ErxChargeItem default initializer
    public init(
        identifier: String,
        fhirData: Data,
        enteredDate: String? = nil,
        medication: ErxMedication? = nil,
        medicationRequest: ErxMedicationRequest = ErxMedicationRequest(),
        patient: ErxPatient? = nil,
        practitioner: ErxPractitioner? = nil,
        organization: ErxOrganization? = nil,
        pharmacy: DavOrganization? = nil,
        invoice: DavInvoice? = nil,
        medicationDispense: DavMedicationDispense? = nil,
        prescriptionSignature: ErxSignature? = nil,
        receiptSignature: ErxSignature? = nil,
        dispenseSignature: ErxSignature? = nil

    ) {
        self.identifier = identifier
        self.fhirData = fhirData
        self.enteredDate = enteredDate
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
    }

    // MARK: Meta Information

    /// Id of the consent
    public var id: String { identifier }
    /// Identifier of the charge item
    public let identifier: String
    /// Complete FHIR bundle as json encoded data
    public let fhirData: Data
    /// Date the charge item was entered
    public let enteredDate: String?

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

    // MARK: Signatures from all bundles

    public let prescriptionSignature: ErxSignature?
    public let receiptSignature: ErxSignature?
    public let dispenseSignature: ErxSignature?
}

extension ErxChargeItem {
    /// Mock data for now, to display something on UI level
    public var medicationText: String {
        "Vitamin C"
    }
}
