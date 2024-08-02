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
//

import CoreData
import Foundation

extension PharmacyEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PharmacyEntity> {
        NSFetchRequest<PharmacyEntity>(entityName: "PharmacyEntity")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var telematikId: String?
    @NSManaged public var created: Date?
    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var phone: String?
    @NSManaged public var fax: String?
    @NSManaged public var web: String?
    @NSManaged public var latitude: NSDecimalNumber?
    @NSManaged public var longitude: NSDecimalNumber?
    @NSManaged public var lastUsed: Date?
    @NSManaged public var street: String?
    @NSManaged public var zip: String?
    @NSManaged public var houseNumber: String?
    @NSManaged public var city: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var imagePath: String?
    @NSManaged public var countUsage: Int32
}

extension PharmacyEntity: Identifiable {}