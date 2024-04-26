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
            entries: IdentifiedArray(
                uniqueElements: entries
            )
        )
    }
}
