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

extension AVSTransactionEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AVSTransactionEntity> {
        NSFetchRequest<AVSTransactionEntity>(entityName: "AVSTransactionEntity")
    }

    @NSManaged public var groupedRedeemID: UUID?
    @NSManaged public var groupedRedeemTime: Date?
    @NSManaged public var httpStatusCode: Int32
    @NSManaged public var telematikID: String?
    @NSManaged public var transactionID: UUID?
    @NSManaged public var erxTask: ErxTaskEntity?
}
