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
//

import CoreData
import Foundation

extension ProfileEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfileEntity> {
        NSFetchRequest<ProfileEntity>(entityName: "ProfileEntity")
    }

    @NSManaged public var color: String?
    @NSManaged public var created: Date?
    @NSManaged public var displayName: String?
    @NSManaged public var familyName: String?
    @NSManaged public var gIdEntry: Data?
    @NSManaged public var givenName: String?
    @NSManaged public var hidePkvConsentDrawerOnMainView: Bool
    @NSManaged public var identifier: UUID?
    @NSManaged public var image: String?
    @NSManaged public var insurance: String?
    @NSManaged public var insuranceId: String?
    @NSManaged public var insuranceIK: String?
    @NSManaged public var insuranceType: String?
    @NSManaged public var lastAuthenticated: Date?
    @NSManaged public var name: String?
    @NSManaged public var userImageData: Data?
    @NSManaged public var shouldAutoUpdateNameAtNextLogin: Bool
    @NSManaged public var chargeItems: NSSet?
    @NSManaged public var erxTasks: NSSet?
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
