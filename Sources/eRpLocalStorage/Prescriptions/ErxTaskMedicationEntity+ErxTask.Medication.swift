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

extension ErxTaskMedicationEntity {
    convenience init?(medication: ErxMedication?,
                      in context: NSManagedObjectContext) {
        guard let medication = medication else { return nil }

        self.init(context: context)

        name = medication.name
        if let medicationAmount = medication.amount {
            amountRatio = ErxTaskRatioEntity(ratio: medicationAmount, in: context)
        }
        dosageForm = medication.dosageForm
        dose = medication.dose
        profile = medication.profile?.rawValue
        pzn = medication.pzn
        lot = medication.batch?.lotNumber
        expiresOn = medication.batch?.expiresOn
        isVaccine = medication.isVaccine
        packaging = medication.packaging
        manufacturingInstructions = medication.manufacturingInstructions
        drugCategory = medication.drugCategory?.rawValue
        let ingredientEntities = medication.ingredients.compactMap {
            ErxTaskIngredientEntity(ingredient: $0, in: context)
        }
        if !ingredientEntities.isEmpty {
            addToIngredients(NSSet(array: ingredientEntities))
        }
    }
}

extension ErxMedication {
    init?(entity: ErxTaskMedicationEntity?) {
        guard let entity = entity else { return nil }

        var batch: ErxMedication.Batch?
        if entity.lot != nil || entity.expiresOn != nil {
            batch = .init(lotNumber: entity.lot, expiresOn: entity.expiresOn)
        }

        self.init(
            name: entity.name,
            profile: ErxMedication.ProfileType(rawValue: entity.profile ?? "nil"),
            drugCategory: ErxMedication.DrugCategory(rawValue: entity.drugCategory ?? "nil"),
            pzn: entity.pzn,
            isVaccine: entity.isVaccine,
            amount: ErxMedication.Ratio(entity: entity.amountRatio),
            dosageForm: entity.dosageForm,
            dose: entity.dose,
            batch: batch,
            packaging: entity.packaging,
            manufacturingInstructions: entity.manufacturingInstructions,
            ingredients: entity.ingredients?.compactMap { entity in
                guard let ingredient = entity as? ErxTaskIngredientEntity else { return nil }
                return Ingredient(entity: ingredient)
            } ?? []
        )
    }
}
