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

extension ErxTaskIngredientEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ErxTaskIngredientEntity> {
        NSFetchRequest<ErxTaskIngredientEntity>(entityName: "ErxTaskIngredientEntity")
    }

    @NSManaged public var text: String?
    @NSManaged public var number: String?
    @NSManaged public var form: String?
    @NSManaged public var strengthFreeText: String?
    @NSManaged public var strengthRatio: ErxTaskRatioEntity?
    @NSManaged public var medication: ErxTaskMedicationEntity?
    @NSManaged public var medicationDispense: ErxTaskMedicationDispenseEntity?
}

extension ErxTaskIngredientEntity: Identifiable {}
