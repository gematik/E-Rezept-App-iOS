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

/// Acts as the intermediate data model from a `ModelsR4.MedicationDispense` resource response
/// and the local store representation
///
/// MedicationDispenses are created by the pharmacy and can contain different medications from the prescription
/// even when the `substitutionAllowed` flag is false
/// Profile: https://simplifier.net/packages/de.abda.erezeptabgabedaten/1.3.0/files/805899
public struct DavMedicationDispense: Hashable, Codable {
    /// Default initializer for a MedicationDispense which represent a ModulesR4.MedicationDispense
    public init(
        identifier: String,
        whenHandedOver: String?,
        taskId: String?
    ) {
        self.identifier = identifier
        self.whenHandedOver = whenHandedOver
        self.taskId = taskId
    }

    /// unique identifier in each `DavMedicationDispense`
    public let identifier: String
    /// Date string representing the actual time of performing the dispense
    public let whenHandedOver: String?

    public let taskId: String?
}
