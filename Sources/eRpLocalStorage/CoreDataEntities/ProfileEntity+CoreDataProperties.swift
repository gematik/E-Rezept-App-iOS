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

extension ProfileEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfileEntity> {
        NSFetchRequest<ProfileEntity>(entityName: "ProfileEntity")
    }

    @NSManaged public var color: String?
    @NSManaged public var created: Date?
    @NSManaged public var familyName: String?
    @NSManaged public var givenName: String?
    @NSManaged public var identifier: UUID?
    @NSManaged public var image: String?
    @NSManaged public var insurance: String?
    @NSManaged public var insuranceId: String?
    @NSManaged public var insuranceType: String?
    @NSManaged public var lastAuthenticated: Date?
    @NSManaged public var name: String?
    @NSManaged public var userImageData: Data?
    @NSManaged public var hidePkvConsentDrawerOnMainView: Bool
    @NSManaged public var chargeItems: NSSet?
    @NSManaged public var erxTasks: NSSet?
    @NSManaged public var gIdEntry: Data?
}

// MARK: Generated accessors for chargeItems

extension ProfileEntity {
    @objc(addChargeItemsObject:)
    @NSManaged public func addToChargeItems(_ value: ErxChargeItemEntity)

    @objc(removeChargeItemsObject:)
    @NSManaged public func removeFromChargeItems(_ value: ErxChargeItemEntity)

    @objc(addChargeItems:)
    @NSManaged public func addToChargeItems(_ values: NSSet)

    @objc(removeChargeItems:)
    @NSManaged public func removeFromChargeItems(_ values: NSSet)
}

// MARK: Generated accessors for erxTasks

extension ProfileEntity {
    @objc(addErxTasksObject:)
    @NSManaged public func addToErxTasks(_ value: ErxTaskEntity)

    @objc(removeErxTasksObject:)
    @NSManaged public func removeFromErxTasks(_ value: ErxTaskEntity)

    @objc(addErxTasks:)
    @NSManaged public func addToErxTasks(_ values: NSSet)

    @objc(removeErxTasks:)
    @NSManaged public func removeFromErxTasks(_ values: NSSet)
}

extension ProfileEntity: Identifiable {}
