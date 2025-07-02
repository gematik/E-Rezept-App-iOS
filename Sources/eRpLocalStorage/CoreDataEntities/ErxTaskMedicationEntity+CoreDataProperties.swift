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
import Foundation

extension ErxTaskMedicationEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ErxTaskMedicationEntity> {
        NSFetchRequest<ErxTaskMedicationEntity>(entityName: "ErxTaskMedicationEntity")
    }

    @NSManaged public var dosageForm: String?
    @NSManaged public var dosageInstructions: String?
    @NSManaged public var dose: String?
    @NSManaged public var drugCategory: String?
    @NSManaged public var expiresOn: String?
    @NSManaged public var isVaccine: Bool
    @NSManaged public var lot: String?
    @NSManaged public var manufacturingInstructions: String?
    @NSManaged public var name: String?
    @NSManaged public var packaging: String?
    @NSManaged public var profile: String?
    @NSManaged public var pzn: String?
    @NSManaged public var amountRatio: ErxTaskRatioEntity?
    @NSManaged public var ingredients: NSSet?
    @NSManaged public var task: ErxTaskEntity?
    @NSManaged public var medicationDispense: ErxTaskMedicationDispenseEntity?
}

// MARK: Generated accessors for ingredients

extension ErxTaskMedicationEntity {
    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: ErxTaskIngredientEntity)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: ErxTaskIngredientEntity)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)
}

extension ErxTaskMedicationEntity: Identifiable {}
