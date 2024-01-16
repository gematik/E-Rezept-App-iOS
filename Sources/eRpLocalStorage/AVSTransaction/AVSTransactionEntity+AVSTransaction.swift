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

extension AVSTransactionEntity {
    static func from(avsTransaction: AVSTransaction,
                     in context: NSManagedObjectContext) -> AVSTransactionEntity {
        AVSTransactionEntity(avsTransaction: avsTransaction, in: context)
    }

    convenience init(avsTransaction: AVSTransaction, in context: NSManagedObjectContext) {
        self.init(context: context)
        transactionID = avsTransaction.transactionID
        httpStatusCode = avsTransaction.httpStatusCode
        groupedRedeemTime = avsTransaction.groupedRedeemTime
        groupedRedeemID = avsTransaction.groupedRedeemID
        telematikID = avsTransaction.telematikID
    }
}

extension AVSTransaction {
    init?(entity: AVSTransactionEntity) {
        guard let transactionID = entity.transactionID,
              let groupedRedeemTime = entity.groupedRedeemTime,
              let groupedRedeemID = entity.groupedRedeemID
        else {
            return nil
        }

        self.init(
            transactionID: transactionID,
            httpStatusCode: entity.httpStatusCode,
            groupedRedeemTime: groupedRedeemTime,
            groupedRedeemID: groupedRedeemID,
            telematikID: entity.telematikID,
            taskId: entity.erxTask?.identifier ?? ""
        )
    }
}
