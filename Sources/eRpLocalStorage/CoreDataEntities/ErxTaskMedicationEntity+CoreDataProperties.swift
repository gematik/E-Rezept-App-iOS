//
//  Copyright (c) 2022 gematik GmbH
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

extension ErxTaskMedicationEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ErxTaskMedicationEntity> {
        NSFetchRequest<ErxTaskMedicationEntity>(entityName: "ErxTaskMedicationEntity")
    }

    @NSManaged public var amount: NSDecimalNumber?
    @NSManaged public var dosageForm: String?
    @NSManaged public var dosageInstructions: String?
    @NSManaged public var dose: String?
    @NSManaged public var expiresOn: String?
    @NSManaged public var lot: String?
    @NSManaged public var name: String?
    @NSManaged public var pzn: String?
    @NSManaged public var task: ErxTaskEntity?
}
