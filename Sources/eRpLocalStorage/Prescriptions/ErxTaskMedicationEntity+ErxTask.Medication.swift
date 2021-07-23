//
//  Copyright (c) 2021 gematik GmbH
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

extension ErxTaskMedicationEntity {
    convenience init?(medication: ErxTask.Medication?,
                      in context: NSManagedObjectContext) {
        guard let medication = medication else { return nil }

        self.init(context: context)

        name = medication.name
        if let medicationAmount = medication.amount {
            amount = NSDecimalNumber(decimal: medicationAmount)
        }
        dosageForm = medication.dosageForm
        dose = medication.dose
        dosageInstructions = medication.dosageInstructions
        pzn = medication.pzn
    }
}

extension ErxTask.Medication {
    init?(entity: ErxTaskMedicationEntity?) {
        guard let entity = entity else { return nil }

        self.init(
            name: entity.name,
            pzn: entity.pzn,
            amount: entity.amount as Decimal?,
            dosageForm: entity.dosageForm,
            dose: entity.dose,
            dosageInstructions: entity.dosageInstructions
        )
    }
}
