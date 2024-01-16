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

import CoreData
import eRpKit

extension ErxTaskQuantityEntity {
    convenience init?(quantity: ErxMedication.Quantity?,
                      in context: NSManagedObjectContext) {
        guard let quantity = quantity else { return nil }

        self.init(context: context)

        value = quantity.value
        unit = quantity.unit
    }
}

extension ErxMedication.Quantity {
    init?(entity: ErxTaskQuantityEntity?) {
        guard let entity = entity,
              let value = entity.value else {
            return nil
        }

        self.init(
            value: value,
            unit: entity.unit
        )
    }
}
