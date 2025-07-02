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
        dose = medication.normSizeCode
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
        let profile = ErxMedication.ProfileType(rawValue: entity.profile ?? "nil")
        self.init(
            name: entity.name,
            profile: profile,
            drugCategory: ErxMedication.DrugCategory(rawValue: entity.drugCategory ?? "nil"),
            pzn: entity.pzn,
            isVaccine: entity.isVaccine,
            amount: ErxMedication.Ratio(entity: entity.amountRatio),
            dosageForm: entity.dosageForm,
            normSizeCode: entity.dose,
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
