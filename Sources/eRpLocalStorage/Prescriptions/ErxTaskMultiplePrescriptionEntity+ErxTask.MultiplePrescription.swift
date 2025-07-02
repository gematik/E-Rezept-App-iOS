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

extension ErxTaskMultiplePrescriptionEntity {
    convenience init?(multiplePrescription: MultiplePrescription?,
                      in context: NSManagedObjectContext) {
        guard let multiplePrescription = multiplePrescription else { return nil }

        self.init(context: context)

        mark = multiplePrescription.mark
        if let numbering = multiplePrescription.numbering {
            self.numbering = NSDecimalNumber(decimal: numbering)
        }
        if let totalNumber = multiplePrescription.totalNumber {
            self.totalNumber = NSDecimalNumber(decimal: totalNumber)
        }
        startPeriod = multiplePrescription.startPeriod
        endPeriod = multiplePrescription.endPeriod
    }
}

extension MultiplePrescription {
    init?(entity: ErxTaskMultiplePrescriptionEntity?) {
        guard let entity = entity else { return nil }

        self.init(
            mark: entity.mark,
            numbering: entity.numbering as Decimal?,
            totalNumber: entity.totalNumber as Decimal?,
            startPeriod: entity.startPeriod,
            endPeriod: entity.endPeriod
        )
    }
}
