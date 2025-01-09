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
