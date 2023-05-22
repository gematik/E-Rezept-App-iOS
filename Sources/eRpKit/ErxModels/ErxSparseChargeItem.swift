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

/// A sparsed version of ErxChargeItem
public struct ErxSparseChargeItem: Identifiable, Hashable {
    /// ErxChargeItem default initializer
    public init(
        identifier: String,
        fhirData: Data,
        enteredDate: String? = nil,
        medication: ErxMedication? = nil,
        invoice: DavInvoice? = nil
    ) {
        self.identifier = identifier
        self.fhirData = fhirData
        self.enteredDate = enteredDate
        self.medication = medication
        self.invoice = invoice
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

    // MARK: DAV profiled FHIR resources

    /// Invoice from an Account
    public let invoice: DavInvoice?
}
