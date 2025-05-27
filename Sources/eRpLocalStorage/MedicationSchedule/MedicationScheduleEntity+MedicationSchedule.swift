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
import IdentifiedCollections

extension MedicationScheduleEntity {
    static func from(schedule: MedicationSchedule,
                     in context: NSManagedObjectContext) -> MedicationScheduleEntity {
        MedicationScheduleEntity(schedule: schedule, in: context)
    }

    convenience init(schedule: MedicationSchedule, in context: NSManagedObjectContext) {
        self.init(context: context)
        id = schedule.id
        start = schedule.start
        end = schedule.end
        title = schedule.title
        body = schedule.dosageInstructions
        taskId = schedule.taskId
        weekdays = schedule.weekdaysToString()
        isActive = schedule.isActive

        let entryEntities = schedule.entries.compactMap {
            MedicationScheduleEntryEntity(entry: $0, in: context)
        }

        if !entryEntities.isEmpty {
            addToEntries(NSSet(array: entryEntities))
        }
    }
}

extension MedicationSchedule {
    // Helper method to convert weekdays to a string for Core Data storage
    func weekdaysToString() -> String {
        weekdays.map { String($0.rawValue) }.sorted().joined(separator: ",")
    }

    // Helper method to convert a string from Core Data to weekdays
    // Note: This method assumes that the string is a comma-separated list of integers
    static func weekdaysFromString(_ string: String?) -> Set<Weekday> {
        // Note:
        // If the string is nil, it hasn't been set yet. This means the device is reading a
        // schedule that was created before the introduction of the weekdays property.
        // Thus it has been the case that all weekdays were selected.

        // For newly created schedules (and DB entities), the weekdays property is set to all weekdays by default.
        // (This is a short cut for a real data base migration step.)
        guard let string = string else {
            return Set(Weekday.allCases)
        }

        if string.isEmpty {
            return Set() // Default to no weekdays if the string is empty
        }

        let weekdayValues = string.split(separator: ",").compactMap { Int(String($0)) }
        return Set(weekdayValues.compactMap { Weekday(rawValue: $0) })
    }
}

extension MedicationSchedule {
    init?(entity: MedicationScheduleEntity) {
        guard let identifier = entity.id,
              let entityStart = entity.start,
              let entityEnd = entity.end,
              let taskId = entity.erxTask?.identifier else {
            return nil
        }

        let entries: [MedicationSchedule.Entry] = (entity.entries?.compactMap { entity in
            guard let entry = entity as? MedicationScheduleEntryEntity else { return nil }
            return MedicationSchedule.Entry(entity: entry)
        } ?? [])
            .sorted {
                ($0.hourComponent, $0.minuteComponent) < ($1.hourComponent, $1.minuteComponent)
            }

        self.init(
            id: identifier,
            start: entityStart,
            end: entityEnd,
            title: entity.title ?? "",
            dosageInstructions: entity.body ?? "",
            taskId: taskId,
            isActive: entity.isActive,
            weekdays: MedicationSchedule.weekdaysFromString(entity.weekdays),
            entries: IdentifiedArray(
                uniqueElements: entries
            )
        )
    }
}
