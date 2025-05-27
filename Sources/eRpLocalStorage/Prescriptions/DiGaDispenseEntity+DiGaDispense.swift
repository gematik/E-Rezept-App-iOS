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

extension DiGaDispenseEntity {
    static func from(diGaDispense: DiGaDispense,
                     in context: NSManagedObjectContext) -> DiGaDispenseEntity? {
        DiGaDispenseEntity(diGaDispense: diGaDispense,
                           in: context)
    }

    convenience init?(
        diGaDispense: DiGaDispense?,
        in context: NSManagedObjectContext
    ) {
        guard let diGaDispense else { return nil }

        self.init(context: context)

        redeemCode = diGaDispense.redeemCode
        deepLink = diGaDispense.deepLink
        isMissingData = diGaDispense.isMissingData
    }
}

extension DiGaDispense {
    init?(entity: DiGaDispenseEntity?) {
        guard let entity = entity else { return nil }

        self.init(
            redeemCode: entity.redeemCode,
            deepLink: entity.deepLink,
            isMissingData: entity.isMissingData
        )
    }
}
