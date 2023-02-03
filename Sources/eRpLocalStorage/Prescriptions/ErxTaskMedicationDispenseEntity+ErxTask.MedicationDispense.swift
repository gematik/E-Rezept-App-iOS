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
    static func from(medicationDispense: ErxTask.MedicationDispense,
                     in context: NSManagedObjectContext) -> ErxTaskMedicationDispenseEntity {
        ErxTaskMedicationDispenseEntity(medicationDispense: medicationDispense,
                                        in: context)
    }

    convenience init(
        medicationDispense: ErxTask.MedicationDispense,
        in context: NSManagedObjectContext
    ) {
        self.init(context: context)

        identifier = medicationDispense.identifier
        taskId = medicationDispense.taskId
        insuranceId = medicationDispense.insuranceId
        pzn = medicationDispense.pzn
        name = medicationDispense.name
        dose = medicationDispense.dose
        dosageForm = medicationDispense.dosageForm
        dosageInstruction = medicationDispense.dosageInstruction
        if let medicationAmount = medicationDispense.amount {
            amount = NSDecimalNumber(decimal: medicationAmount)
        }
        telematikId = medicationDispense.telematikId
        whenHandedOver = medicationDispense.whenHandedOver
        lot = medicationDispense.lot
        expiresOn = medicationDispense.expiresOn
    }
}

extension ErxTask.MedicationDispense {
    init?(entity: ErxTaskMedicationDispenseEntity?) {
        guard let entity = entity,
              let id = entity.identifier,
              let taskId = entity.taskId,
              let insuranceId = entity.insuranceId,
              let pzn = entity.pzn,
              let telematikId = entity.telematikId,
              let whenHandedOver = entity.whenHandedOver else {
            return nil
        }

        self.init(
            identifier: id,
            taskId: taskId,
            insuranceId: insuranceId,
            pzn: pzn,
            name: entity.name,
            dose: entity.dose,
            dosageForm: entity.dosageForm,
            dosageInstruction: entity.dosageInstruction,
            amount: entity.amount as Decimal?,
            telematikId: telematikId,
            whenHandedOver: whenHandedOver,
            lot: entity.lot,
            expiresOn: entity.expiresOn
        )
    }
}
