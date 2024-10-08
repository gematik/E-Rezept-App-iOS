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

extension PharmacyEntity {
    static func from(pharmacyLocation: PharmacyLocation,
                     in context: NSManagedObjectContext) -> PharmacyEntity {
        PharmacyEntity(pharmacyLocation: pharmacyLocation, in: context)
    }

    convenience init(pharmacyLocation: PharmacyLocation,
                     in context: NSManagedObjectContext) {
        self.init(context: context)
        identifier = pharmacyLocation.id
        telematikId = pharmacyLocation.telematikID
        created = pharmacyLocation.created
        name = pharmacyLocation.name
        email = pharmacyLocation.telecom?.email
        phone = pharmacyLocation.telecom?.phone
        fax = pharmacyLocation.telecom?.fax
        web = pharmacyLocation.telecom?.web
        latitude = pharmacyLocation.position?.latitude as? NSDecimalNumber
        longitude = pharmacyLocation.position?.longitude as? NSDecimalNumber
        lastUsed = pharmacyLocation.lastUsed
        street = pharmacyLocation.address?.street
        zip = pharmacyLocation.address?.zip
        houseNumber = pharmacyLocation.address?.houseNumber
        city = pharmacyLocation.address?.city
        isFavorite = pharmacyLocation.isFavorite
        imagePath = pharmacyLocation.imagePath
        countUsage = Int32(pharmacyLocation.countUsage)
    }
}

extension PharmacyLocation {
    init?(entity: PharmacyEntity) {
        guard let identifier = entity.identifier,
              let telematikId = entity.telematikId,
              let created = entity.created else {
            return nil
        }

        var position: PharmacyLocation.Position?
        if let lat = entity.latitude as? Decimal,
           let long = entity.longitude as? Decimal {
            position = PharmacyLocation.Position(
                latitude: lat,
                longitude: long
            )
        }

        var telecom: PharmacyLocation.Telecom?
        if entity.phone != nil || entity.fax != nil || entity.email != nil || entity.web != nil {
            telecom = PharmacyLocation.Telecom(
                phone: entity.phone,
                fax: entity.fax,
                email: entity.email,
                web: entity.web
            )
        }

        var address: PharmacyLocation.Address?
        if entity.street != nil || entity.houseNumber != nil || entity.zip != nil || entity.city != nil {
            address = Address(
                street: entity.street,
                houseNumber: entity.houseNumber,
                zip: entity.zip,
                city: entity.city
            )
        }

        self.init(
            id: identifier,
            status: nil,
            telematikID: telematikId,
            created: created,
            name: entity.name,
            types: [],
            position: position,
            address: address,
            telecom: telecom,
            lastUsed: entity.lastUsed,
            isFavorite: entity.isFavorite,
            imagePath: entity.imagePath,
            countUsage: Int(entity.countUsage),
            hoursOfOperation: []
        )
    }
}
