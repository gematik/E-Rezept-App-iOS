//
//  Copyright (c) 2022 gematik GmbH
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
    public struct Medication: Hashable {
        public init(name: String? = nil,
                    pzn: String? = nil,
                    amount: Decimal? = nil,
                    dosageForm: String? = nil,
                    dose: String? = nil,
                    dosageInstructions: String? = nil,
                    lot: String? = nil,
                    expiresOn: String? = nil) {
            self.name = name
            self.pzn = pzn
            self.amount = amount
            self.dosageForm = dosageForm
            self.dose = dose
            self.dosageInstructions = dosageInstructions
            self.lot = lot
            self.expiresOn = expiresOn
        }

        public let name: String?
        public let pzn: String?
        public let amount: Decimal?
        public let dosageForm: String?
        public let dose: String?
        public let dosageInstructions: String?
        public let lot: String?
        public let expiresOn: String?
    }
}
