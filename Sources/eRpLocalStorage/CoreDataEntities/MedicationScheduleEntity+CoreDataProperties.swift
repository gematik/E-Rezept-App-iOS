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
