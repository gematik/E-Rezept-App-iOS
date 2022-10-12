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

import eRpKit
import Foundation
import IdentifiedCollections
import Pharmacy

struct OrderCommunications: Identifiable, Equatable {
    // if no oderId is send while redeeming, group orders into one unknown group
    static let unknownOderId = "unknown"
    let orderId: String
    let telematikId: String
    let communications: IdentifiedArrayOf<ErxTask.Communication>
    /// displayed communications are a subset of communications
    /// without duplicates as defined by `ErxTask.Communication.Unique`
    let displayedCommunications: IdentifiedArrayOf<ErxTask.Communication>

    var pharmacy: PharmacyLocation?

    var id: String { orderId }

    var hasNewCommunications: Bool {
        communications.contains { !$0.isRead }
    }

    var prescriptionCount: Int {
        Set(communications.map(\.taskId)).count
    }

    var lastUpdated: String {
        communications.max { $0.timestamp > $1.timestamp }?.timestamp ?? ""
    }

    init(orderId: String, communications: [ErxTask.Communication], pharmacy: PharmacyLocation? = nil) {
        self.orderId = orderId
        telematikId = communications.first?.telematikId ?? ""
        self.communications = IdentifiedArray(uniqueElements: communications)
        displayedCommunications = IdentifiedArray(uniqueElements: communications.filterUnique())
        if orderId == Self.unknownOderId {
            self.pharmacy = PharmacyLocation(
                id: "",
                status: nil,
                telematikID: "",
                name: L10n.ordTxtNoPharmacyName.text,
                types: [],
                hoursOfOperation: []
            )
        } else {
            self.pharmacy = pharmacy
        }
    }
}

extension OrderCommunications: Comparable {
    static func <(lhs: OrderCommunications, rhs: OrderCommunications) -> Bool {
        lhs.lastUpdated > rhs.lastUpdated
    }
}
