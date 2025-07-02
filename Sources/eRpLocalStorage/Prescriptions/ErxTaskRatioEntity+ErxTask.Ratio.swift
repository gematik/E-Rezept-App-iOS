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

import CoreData
import eRpKit

extension ErxTaskRatioEntity {
    convenience init?(ratio: ErxMedication.Ratio?,
                      in context: NSManagedObjectContext) {
        guard let ratio = ratio else { return nil }

        self.init(context: context)

        numerator = ErxTaskQuantityEntity(quantity: ratio.numerator, in: context)
        denominator = ErxTaskQuantityEntity(quantity: ratio.denominator, in: context)
    }
}

extension ErxMedication.Ratio {
    init?(entity: ErxTaskRatioEntity?) {
        guard let entity = entity,
              let numeratorValue = entity.numerator?.value else { return nil }

        var denominator: ErxMedication.Quantity?
        if let denominatorValue = entity.denominator?.value {
            denominator = ErxMedication.Quantity(
                value: denominatorValue,
                unit: entity.denominator?.unit
            )
        }

        self.init(
            numerator: .init(value: numeratorValue, unit: entity.numerator?.unit),
            denominator: denominator
        )
    }
}
