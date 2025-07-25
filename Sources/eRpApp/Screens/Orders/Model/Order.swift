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
    let timelineEntries: [TimelineEntry]

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
        let communicationTimestamp = communications.max { $0.timestamp < $1.timestamp }?.timestamp ?? ""
        if let chargeItemTimestamp = chargeItems.max(by: { $0.enteredDate ?? "" < $1.enteredDate ?? "" })?.enteredDate {
            lastUpdated = [communicationTimestamp, chargeItemTimestamp].max(by: <) ?? ""
        } else {
            lastUpdated = communicationTimestamp
        }
        tasksCount = Set(communications.map(\.taskId)).count
        timelineEntries = {
            let displayedCommunications = IdentifiedArray(uniqueElements: communications.filterUnique())
            var timelineEntries: [TimelineEntry] = displayedCommunications.compactMap { communication in
                switch communication.profile {
                case .dispReq:
                    return .dispReq(communication, pharmacy: pharmacy, chipTexts: [])
                case .reply:
                    return .reply(communication, chipTexts: [])
                default:
                    return nil
                }
            }
            timelineEntries.append(contentsOf: chargeItems.map { TimelineEntry.chargeItem($0) })
            return timelineEntries.sorted { $0.lastUpdated > $1.lastUpdated }
        }()
    }

    var latestMessage: String {
        timelineEntries.first?.text ?? ""
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

        static let orderCommunications2 = {
            var readCommunication = ErxChargeItem.Dummies.dummy
            readCommunication.isRead = true
            return Order(
                orderId: "orderId_2",
                communications: IdentifiedArrayOf(uniqueElements: ErxTask.Communication.Dummies
                    .multipleCommunications2),
                chargeItems: IdentifiedArrayOf(arrayLiteral: readCommunication),
                pharmacy: PharmacyLocation.Dummies.pharmacy
            )
        }()
    }
}

extension Order {
    /// This initialiser is only used for testing purposes
    ///
    /// - Important: timelineEntries property should only be used for testing
    init(
        orderId: String,
        communications: IdentifiedArrayOf<ErxTask.Communication>,
        chargeItems: IdentifiedArrayOf<ErxChargeItem>,
        pharmacy: PharmacyLocation? = nil,
        timelineEntries: [TimelineEntry] = []
    ) {
        self.orderId = orderId
        self.communications = communications
        self.chargeItems = chargeItems
        self.pharmacy = pharmacy
        let communicationTimestamp = communications.max { $0.timestamp < $1.timestamp }?.timestamp ?? ""
        if let chargeItemTimestamp = chargeItems.max(by: { $0.enteredDate ?? "" < $1.enteredDate ?? "" })?
            .enteredDate {
            lastUpdated = [communicationTimestamp, chargeItemTimestamp].max(by: <) ?? ""
        } else {
            lastUpdated = communicationTimestamp
        }
        tasksCount = Set(communications.map(\.taskId)).count
        self.timelineEntries = timelineEntries
    }
}
