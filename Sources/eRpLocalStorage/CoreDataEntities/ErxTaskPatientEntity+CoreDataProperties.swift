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
import Foundation

extension ErxTaskPatientEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ErxTaskPatientEntity> {
        NSFetchRequest<ErxTaskPatientEntity>(entityName: "ErxTaskPatientEntity")
    }

    @NSManaged public var address: String?
    @NSManaged public var birthDate: String?
    @NSManaged public var insurance: String?
    @NSManaged public var insuranceIdentifier: String?
    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var status: String?
    @NSManaged public var task: ErxTaskEntity?
}
