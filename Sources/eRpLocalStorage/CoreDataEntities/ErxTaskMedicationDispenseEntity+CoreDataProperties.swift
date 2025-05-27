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

extension ErxTaskMedicationDispenseEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ErxTaskMedicationDispenseEntity> {
        NSFetchRequest<ErxTaskMedicationDispenseEntity>(entityName: "ErxTaskMedicationDispenseEntity")
    }

    @NSManaged public var dosageInstruction: String?
    @NSManaged public var identifier: String?
    @NSManaged public var insuranceId: String?
    @NSManaged public var taskId: String?
    @NSManaged public var telematikId: String?
    @NSManaged public var whenHandedOver: String?
    @NSManaged public var noteText: String?
    @NSManaged public var task: ErxTaskEntity?
    @NSManaged public var quantity: ErxTaskQuantityEntity?
    @NSManaged public var medication: ErxTaskMedicationEntity?
    @NSManaged public var epaMedication: ErxEpaMedicationEntity?
    @NSManaged public var digaDispense: DiGaDispenseEntity?
}

extension ErxTaskMedicationDispenseEntity: Identifiable {}
