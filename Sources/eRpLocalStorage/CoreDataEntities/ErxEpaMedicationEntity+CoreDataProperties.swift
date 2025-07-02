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

extension ErxEpaMedicationEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ErxEpaMedicationEntity> {
        NSFetchRequest<ErxEpaMedicationEntity>(entityName: "ErxEpaMedicationEntity")
    }

    @NSManaged public var epaMedicationType: Data?
    @NSManaged public var drugCategory: Data?
    @NSManaged public var code: Data?
    @NSManaged public var status: Data?
    @NSManaged public var vaccine: NSNumber?
    @NSManaged public var amount: Data?
    @NSManaged public var form: Data?
    @NSManaged public var normSizeCode: String?
    @NSManaged public var batch: Data?
    @NSManaged public var packaging: String?
    @NSManaged public var manufacturingInstructions: String?
    @NSManaged public var ingredients: Data?
}

extension ErxEpaMedicationEntity: Identifiable {}
