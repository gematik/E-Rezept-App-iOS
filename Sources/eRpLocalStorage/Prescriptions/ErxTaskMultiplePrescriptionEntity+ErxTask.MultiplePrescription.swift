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
