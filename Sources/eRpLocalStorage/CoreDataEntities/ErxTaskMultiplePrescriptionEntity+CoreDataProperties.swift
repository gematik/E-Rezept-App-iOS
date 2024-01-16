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
//

import CoreData
import Foundation

extension ErxTaskMultiplePrescriptionEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ErxTaskMultiplePrescriptionEntity> {
        NSFetchRequest<ErxTaskMultiplePrescriptionEntity>(entityName: "ErxTaskMultiplePrescriptionEntity")
    }

    @NSManaged public var mark: Bool
    @NSManaged public var numbering: NSDecimalNumber?
    @NSManaged public var totalNumber: NSDecimalNumber?
    @NSManaged public var startPeriod: String?
    @NSManaged public var endPeriod: String?
    @NSManaged public var task: ErxTaskEntity?
}
