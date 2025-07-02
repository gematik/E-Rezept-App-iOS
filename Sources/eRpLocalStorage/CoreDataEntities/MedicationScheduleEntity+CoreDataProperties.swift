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
import Foundation

extension MedicationScheduleEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MedicationScheduleEntity> {
        NSFetchRequest<MedicationScheduleEntity>(entityName: "MedicationScheduleEntity")
    }

    @NSManaged public var body: String?
    @NSManaged public var end: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var start: Date?
    @NSManaged public var taskId: String?
    @NSManaged public var title: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var entries: NSSet?
    @NSManaged public var weekdays: String?
    @NSManaged public var erxTask: ErxTaskEntity?
}

// MARK: Generated accessors for entries

extension MedicationScheduleEntity {
    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: MedicationScheduleEntryEntity)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: MedicationScheduleEntryEntity)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSSet)
}
