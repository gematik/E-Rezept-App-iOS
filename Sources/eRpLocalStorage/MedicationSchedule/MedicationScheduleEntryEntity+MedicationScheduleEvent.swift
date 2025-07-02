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
import eRpKit

extension MedicationScheduleEntryEntity {
    static func from(entry: MedicationSchedule.Entry,
                     in context: NSManagedObjectContext) -> MedicationScheduleEntryEntity {
        MedicationScheduleEntryEntity(entry: entry, in: context)
    }

    convenience init(entry: MedicationSchedule.Entry, in context: NSManagedObjectContext) {
        self.init(context: context)
        id = entry.id
        title = entry.title
        hourComponent = Int32(entry.hourComponent)
        minuteComponent = Int32(entry.minuteComponent)
        dosageForm = entry.dosageForm
        amount = entry.amount
    }
}

extension MedicationSchedule.Entry {
    init?(entity: MedicationScheduleEntryEntity) {
        guard let identifier = entity.id
        else {
            return nil
        }

        self.init(
            id: identifier,
            title: entity.title ?? "",
            hourComponent: Int(entity.hourComponent),
            minuteComponent: Int(entity.minuteComponent),
            dosageForm: entity.dosageForm ?? "",
            amount: entity.amount ?? ""
        )
    }
}
