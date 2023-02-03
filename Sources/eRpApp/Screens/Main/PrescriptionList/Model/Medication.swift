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

struct Medication: Equatable, Hashable {
    let pzn: String?
    let dose: String?
    let amount: Decimal?
    let name: String?
    let dosageInstruction: String?
    let dosageForm: String?
    let handedOver: String?
    let lot: String?
    let expiresOn: String?

    static func from(medicationDispense: ErxTask.MedicationDispense) -> Medication {
        self.init(
            pzn: medicationDispense.pzn,
            dose: medicationDispense.dose,
            amount: medicationDispense.amount,
            name: medicationDispense.name,
            dosageInstruction: medicationDispense.dosageInstruction,
            dosageForm: medicationDispense.dosageForm,
            handedOver: medicationDispense.whenHandedOver,
            lot: medicationDispense.lot,
            expiresOn: medicationDispense.expiresOn
        )
    }

    static func from(medication: ErxTask.Medication, redeemedOn: String?) -> Medication {
        self.init(
            pzn: medication.pzn,
            dose: medication.dose,
            amount: medication.amount,
            name: medication.name,
            dosageInstruction: medication.dosageInstructions,
            dosageForm: medication.dosageForm,
            handedOver: redeemedOn,
            lot: medication.lot,
            expiresOn: medication.expiresOn
        )
    }
}

extension Medication: Comparable {
    public static func <(lhs: Medication, rhs: Medication) -> Bool {
        switch (lhs.name, rhs.name) {
        case (_, nil): return true
        case (nil, _): return false
        case let (.some(lhsValue), .some(rhsValue)): return lhsValue < rhsValue
        }
    }
}
