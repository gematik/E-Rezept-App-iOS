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

import CoreData
import eRpKit

extension ShipmentInfoEntity {
    static func from(shipmentInfo: ShipmentInfo,
                     in context: NSManagedObjectContext) -> ShipmentInfoEntity {
        ShipmentInfoEntity(shipmentInfo: shipmentInfo, in: context)
    }

    convenience init(shipmentInfo: ShipmentInfo, in context: NSManagedObjectContext) {
        self.init(context: context)
        identifier = shipmentInfo.identifier
        name = shipmentInfo.name
        street = shipmentInfo.street
        addressDetail = shipmentInfo.addressDetail
        zip = shipmentInfo.zip
        city = shipmentInfo.city
        phone = shipmentInfo.phone
        mail = shipmentInfo.mail
        deliveryInfo = shipmentInfo.deliveryInfo
    }
}

extension ShipmentInfo {
    init?(entity: ShipmentInfoEntity) {
        guard let identifier = entity.identifier else {
            return nil
        }

        self.init(
            identifier: identifier,
            name: entity.name,
            street: entity.street,
            addressDetail: entity.addressDetail,
            zip: entity.zip,
            city: entity.city,
            phone: entity.phone,
            mail: entity.mail,
            deliveryInfo: entity.deliveryInfo
        )
    }
}
