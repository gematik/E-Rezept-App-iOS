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

import eRpKit
import Foundation

extension ErxTask {
    var isRedeemed: Bool {
        medicationDispense != nil || redeemedOn != nil
    }

    /// `true` if the medication is dispensed and was substituted with an alternative medication, `false` otherwise.
    var isMedicationSubstituted: Bool {
        guard let medicationPZN = medication?.pzn,
              let medicationDispPZN = medicationDispense?.pzn else {
            return false
        }
        return medicationPZN != medicationDispPZN
    }

    var whenHandedOver: String? {
        if isMedicationSubstituted {
            return medicationDispense?.whenHandedOver
        }
        return redeemedOn
    }

    var medicationName: String? {
        if isMedicationSubstituted {
            return medicationDispense?.name
        } else {
            return medication?.name
        }
    }

    var medicationDosageForm: String? {
        if isMedicationSubstituted {
            return medicationDispense?.dosageForm
        } else {
            return medication?.dosageForm
        }
    }

    var medicationDosageInstructions: String? {
        if isMedicationSubstituted {
            return medicationDispense?.dosageInstruction
        } else {
            return medication?.dosageInstructions
        }
    }

    var medicationPZN: String? {
        if isMedicationSubstituted {
            return medicationDispense?.pzn
        } else {
            return medication?.pzn
        }
    }

    var medicationDose: String? {
        if isMedicationSubstituted {
            return medicationDispense?.dose
        } else {
            return medication?.dose
        }
    }

    var medicationAmount: Decimal? {
        if isMedicationSubstituted {
            return medicationDispense?.amount
        } else {
            return medication?.amount
        }
    }
}
