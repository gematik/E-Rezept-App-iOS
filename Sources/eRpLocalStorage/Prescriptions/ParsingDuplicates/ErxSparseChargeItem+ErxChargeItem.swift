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
import ModelsR4

extension ErxSparseChargeItem {
    /// Extracts all held information from the fhirData value
    /// and returns a detailed `ErxChargeItem`
    public var chargeItem: ErxChargeItem? {
        try? parseErxChargeItem()
    }

    func parseErxChargeItem(
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> ErxChargeItem? {
        let bundle = try decoder.decode(ModelsR4.Bundle.self, from: fhirData)
        let chargeItem = try bundle.parseErxChargeItem(id: id, with: fhirData)

        return chargeItem
    }
}
