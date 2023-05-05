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

struct Medication: Hashable, Comparable {
    let pzn: String?
    let dose: String?
    let amount: ErxMedication.Ratio?
    let name: String?
    let dosageInstruction: String?
    let dosageForm: String?
    let handedOver: String?
    let lot: String?
    let expiresOn: String?
    let ingredients: [ErxMedication.Ingredient]

    var displayName: String {
        if let name = name {
            return name
        } else {
            let joinedText = ingredients.compactMap(\.text).joined(separator: ", ")
            guard !joinedText.isEmpty else { return L10n.prscTxtFallbackName.text }
            return joinedText
        }
    }

    static func from(medicationDispense: ErxMedicationDispense) -> Medication {
        self.init(
            pzn: medicationDispense.medication?.pzn,
            dose: medicationDispense.medication?.dose,
            amount: medicationDispense.medication?.amount,
            name: medicationDispense.medication?.name,
            dosageInstruction: medicationDispense.dosageInstruction,
            dosageForm: medicationDispense.medication?.dosageForm,
            handedOver: medicationDispense.whenHandedOver,
            lot: medicationDispense.medication?.batch?.lotNumber,
            expiresOn: medicationDispense.medication?.batch?.expiresOn,
            ingredients: medicationDispense.medication?.ingredients ?? []
        )
    }

    static func from(medication: ErxMedication, dosageInstructions: String?, redeemedOn: String?) -> Medication {
        self.init(
            pzn: medication.pzn,
            dose: medication.dose,
            amount: medication.amount,
            name: medication.name,
            dosageInstruction: dosageInstructions,
            dosageForm: medication.dosageForm,
            handedOver: redeemedOn,
            lot: medication.batch?.lotNumber,
            expiresOn: medication.batch?.expiresOn,
            ingredients: medication.ingredients
        )
    }

    static func <(lhs: Medication, rhs: Medication) -> Bool {
        switch (lhs.name, rhs.name) {
        case (_, nil): return true
        case (nil, _): return false
        case let (.some(lhsValue), .some(rhsValue)): return lhsValue < rhsValue
        }
    }
}
