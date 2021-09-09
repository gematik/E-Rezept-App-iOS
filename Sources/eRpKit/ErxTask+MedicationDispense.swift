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

import Foundation

extension ErxTask {
    /// Acts as the intermediate data model from a MedicationDispense resource response
    /// and the local store representation
    public struct MedicationDispense: Equatable {
        /// Default initializer for a MedicationDispense which represent a ModulesR4.MedicationDispense
        /// - Parameters:
        ///   - taskId: id of the related `ErkTask`
        ///   - insuranceId: KVNR of the user
        ///   - pzn: Product number of a medication
        ///   - name: Describing text or name of the medication dispense
        ///   - dosageForm: Form of dosage (e.g.: "TAB")
        ///   - dosageInstruction: Instructions for the dosage of the medication
        ///   - telematikId: Telematik-ID of the pharmacy performing the dispense
        ///   - whenHandedOver: Date string representing the actual time of performing the dispense
        public init(
            taskId: String,
            insuranceId: String,
            pzn: String,
            name: String?,
            dose: String?,
            dosageForm: String?,
            dosageInstruction: String?,
            amount: Decimal?,
            telematikId: String,
            whenHandedOver: String
        ) {
            self.taskId = taskId
            self.insuranceId = insuranceId
            self.pzn = pzn
            self.name = name
            self.dose = dose
            self.dosageForm = dosageForm
            self.dosageInstruction = dosageInstruction
            self.amount = amount
            self.telematikId = telematikId
            self.whenHandedOver = whenHandedOver
        }

        /// id of the related `ErkTask` can also be used as the ID of the MedicationDispense
        public let taskId: String
        /// KVNR of the user (e.g.: "X110461389")
        public let insuranceId: String
        /// Product number of a medication (PZN = Pharma Zentral Nummer)
        public let pzn: String
        /// Describing text or name of the medication dispense
        public let name: String?
        /// Informations about the size of the medication package
        public let dose: String?
        /// Form of dosage (e.g.: "TAB")
        public let dosageForm: String?
        /// Instructions for the dosage of the medication
        public let dosageInstruction: String?
        /// Informations about the medication amount
        public let amount: Decimal?
        /// Telematik-ID of the pharmacy performing the dispense
        public let telematikId: String
        /// Date string representing the actual time of performing the dispense
        public let whenHandedOver: String
    }
}
