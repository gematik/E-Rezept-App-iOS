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

/// A sparsed version of ErxChargeItem
public struct ErxSparseChargeItem: Identifiable, Hashable, Codable {
    /// ErxChargeItem default initializer
    public init(
        identifier: String,
        taskId: String?,
        fhirData: Data,
        enteredDate: String? = nil,
        isRead: Bool = false,
        medication: ErxMedication? = nil,
        invoice: DavInvoice? = nil
    ) {
        self.identifier = identifier
        self.taskId = taskId
        self.fhirData = fhirData
        self.enteredDate = enteredDate
        self.isRead = isRead
        self.medication = medication
        self.invoice = invoice
    }

    // MARK: Meta Information

    /// Id of the consent
    public var id: String { identifier }
    /// Identifier of the charge item
    public let identifier: String
    /// Identifier of the related ErxTask
    public var taskId: String?
    /// Complete FHIR bundle as json encoded data
    public let fhirData: Data
    /// Date the charge item was entered
    public let enteredDate: String?
    /// Indicates if the message about the ChargeItem in the order section has been opened by the user
    public let isRead: Bool

    // MARK: KBV profiled FHIR resources

    /// The prescribed medication
    public let medication: ErxMedication?

    // MARK: DAV profiled FHIR resources

    /// Invoice from an Account
    public let invoice: DavInvoice?
}
