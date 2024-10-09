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

extension ErxTaskIngredientEntity {
    convenience init?(ingredient: ErxMedication.Ingredient?,
                      in context: NSManagedObjectContext) {
        guard let ingredient = ingredient else { return nil }

        self.init(context: context)

        text = ingredient.text
        number = ingredient.number
        form = ingredient.form
        strengthRatio = ErxTaskRatioEntity(ratio: ingredient.strength, in: context)
        strengthFreeText = ingredient.strengthFreeText
    }
}

extension ErxMedication.Ingredient {
    init?(entity: ErxTaskIngredientEntity?) {
        guard let entity = entity else { return nil }
        self.init(
            text: entity.text,
            number: entity.number,
            form: entity.form,
            strength: ErxMedication.Ratio(entity: entity.strengthRatio),
            strengthFreeText: entity.strengthFreeText
        )
    }
}
