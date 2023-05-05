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

extension ErxTaskMedicationDispenseEntity {
    static func from(medicationDispense: ErxMedicationDispense,
                     in context: NSManagedObjectContext) -> ErxTaskMedicationDispenseEntity {
        ErxTaskMedicationDispenseEntity(medicationDispense: medicationDispense,
                                        in: context)
    }

    convenience init(
        medicationDispense: ErxMedicationDispense,
        in context: NSManagedObjectContext
    ) {
        self.init(context: context)

        identifier = medicationDispense.identifier
        taskId = medicationDispense.taskId
        insuranceId = medicationDispense.insuranceId
        dosageInstruction = medicationDispense.dosageInstruction
        telematikId = medicationDispense.telematikId
        whenHandedOver = medicationDispense.whenHandedOver
        noteText = medicationDispense.noteText
        quantity = ErxTaskQuantityEntity(quantity: medicationDispense.quantity, in: context)
        medication = ErxTaskMedicationEntity(medication: medicationDispense.medication, in: context)
    }
}

extension ErxMedicationDispense {
    init?(entity: ErxTaskMedicationDispenseEntity?) {
        guard let entity = entity,
              let taskId = entity.taskId,
              let identifier = entity.identifier else {
            return nil
        }

        var quantity: ErxMedication.Quantity?
        if let value = entity.quantity?.value {
            quantity = .init(value: value, unit: entity.quantity?.unit)
        }

        self.init(
            identifier: identifier,
            taskId: taskId,
            insuranceId: entity.insuranceId,
            dosageInstruction: entity.dosageInstruction,
            telematikId: entity.telematikId,
            whenHandedOver: entity.whenHandedOver,
            quantity: quantity,
            noteText: entity.noteText,
            medication: ErxMedication(entity: entity.medication)
        )
    }
}
