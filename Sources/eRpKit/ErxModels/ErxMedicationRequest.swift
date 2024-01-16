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

public struct ErxMedicationRequest: Hashable, Codable {
    public init(
        authoredOn: String? = nil,
        dosageInstructions: String? = nil,
        substitutionAllowed: Bool? = false,
        hasEmergencyServiceFee: Bool? = false,
        dispenseValidityEnd: String? = nil,
        accidentInfo: AccidentInfo? = nil,
        bvg: Bool? = false,
        coPaymentStatus: ErxTask.CoPaymentStatus? = nil,
        multiplePrescription: MultiplePrescription? = nil,
        quantity: ErxMedication.Quantity? = nil
    ) {
        self.authoredOn = authoredOn
        self.dosageInstructions = dosageInstructions
        self.substitutionAllowed = substitutionAllowed ?? false
        self.hasEmergencyServiceFee = hasEmergencyServiceFee ?? false
        self.dispenseValidityEnd = dispenseValidityEnd
        self.accidentInfo = accidentInfo
        self.bvg = bvg ?? false
        self.coPaymentStatus = coPaymentStatus
        self.multiplePrescription = multiplePrescription
        self.quantity = quantity
    }

    public let authoredOn: String?
    /// Indicates how the medication is to be used by the patient.
    public let dosageInstructions: String?
    /// Whether substitution is allowed (Aut-Idem)
    public let substitutionAllowed: Bool
    /// Indicates emergency service fee (Notdienstgebühr)
    public let hasEmergencyServiceFee: Bool
    /// The end date of the medication's dispense validity
    public let dispenseValidityEnd: String?
    /// Work-related accident info
    public let accidentInfo: AccidentInfo?
    /// Indicates if this prescription is related to the
    /// 'Bundesentschädigungsgesetz' or 'Bundesversorgungsgesetz'
    public let bvg: Bool
    /// Indicates if additional charges are applied
    public let coPaymentStatus: ErxTask.CoPaymentStatus?
    /// Information about multiple tasks (e.g. prescription)
    public let multiplePrescription: MultiplePrescription?
    /// Indicates the number of packages of the prescribed medication
    public let quantity: ErxMedication.Quantity?
}
