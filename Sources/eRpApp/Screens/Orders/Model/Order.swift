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

import eRpKit
import Foundation
import IdentifiedCollections
import Pharmacy

struct Order: Identifiable, Equatable {
    static let unknownOrderId = "unknown"
    let orderId: String
    var id: String { orderId }
    let communications: IdentifiedArrayOf<ErxTask.Communication>
    let chargeItems: IdentifiedArrayOf<ErxChargeItem>
    let pharmacy: PharmacyLocation?
    let lastUpdated: String
    let tasksCount: Int

    init(
        orderId: String,
        communications: IdentifiedArrayOf<ErxTask.Communication>,
        chargeItems: IdentifiedArrayOf<ErxChargeItem>,
        pharmacy: PharmacyLocation? = nil
    ) {
        self.orderId = orderId
        self.communications = communications
        self.chargeItems = chargeItems
        self.pharmacy = pharmacy
        let communicationTimestamp = communications.max { $0.timestamp > $1.timestamp }?.timestamp ?? ""
        if let chargeItemTimestamp = chargeItems.max(by: { $0.enteredDate ?? "" > $1.enteredDate ?? "" })?.enteredDate {
            lastUpdated = [communicationTimestamp, chargeItemTimestamp].max(by: >) ?? ""
        } else {
            lastUpdated = communicationTimestamp
        }
        tasksCount = Set(communications.map(\.taskId)).count
    }

    var hasUnreadEntries: Bool {
        communications.contains { !$0.isRead } || chargeItems.contains { !$0.isRead }
    }
}

extension Order: Comparable {
    static func <(lhs: Order, rhs: Order) -> Bool {
        lhs.lastUpdated > rhs.lastUpdated
    }
}

extension Order {
    enum Dummies {
        static let multipleOrderCommunications = [orderCommunications1, orderCommunications2]

        static let orderCommunications1 =
            Order(
                orderId: "orderId_1",
                communications: IdentifiedArrayOf(
                    uniqueElements: ErxTask.Communication.Dummies.multipleCommunications1
                ),

                chargeItems: IdentifiedArrayOf(arrayLiteral: ErxChargeItem.Dummies.dummy)
            )

        static let orderCommunications2 =
            Order(
                orderId: "orderId_2",
                communications: IdentifiedArrayOf(uniqueElements: ErxTask.Communication.Dummies
                    .multipleCommunications2),
                chargeItems: IdentifiedArrayOf(arrayLiteral: ErxChargeItem.Dummies.dummy),
                pharmacy: PharmacyLocation.Dummies.pharmacy
            )
    }
}
