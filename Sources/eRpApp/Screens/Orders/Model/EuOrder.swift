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

import Dependencies
import eRpKit
import Foundation
import IdentifiedCollections
import Pharmacy

struct EuOrder: Identifiable, Equatable {
    static let unknownOrderId = "unknown"
    static let unknownCountryCode = "unknownCountryCode"

    let orderId: String
    var id: String {
        orderId
    }

    let countryCode: String
    let communications: IdentifiedArrayOf<EuCommunication>
    let erxTasks: [ErxTask] // Task events are missing, related tasks + task events
    let lastUpdated: String
    let tasksCount: Int
    let timelineEntries: [TimelineEntry]

    init(
        orderId: String,
        communications: IdentifiedArrayOf<EuCommunication>,
        countryCode: String,
        erxTasks: [ErxTask]
    ) {
        self.orderId = orderId
        self.erxTasks = erxTasks
        self.countryCode = countryCode
        self.communications = communications
        // Transform Date into FHIR-DateString else the sorting is wrong later on
        @Dependency(\.fhirDateFormatter) var formatter: FHIRDateFormatter
        lastUpdated = {
            let communicationsTimestamps = communications.compactMap(\.timestamp)
            guard let date = communicationsTimestamps.max() else {
                return ""
            }
            return formatter.stringWithLongUTCTimeZone(from: date)
        }()
        tasksCount = erxTasks.count
        timelineEntries = {
            let displayedCommunications = IdentifiedArray(uniqueElements: communications)
            var timelineEntries: [TimelineEntry] = []
            // Set Chiptext for EuCommunications that have an taskId
            timelineEntries.append(contentsOf: displayedCommunications.map { item in
                if item.euAccessCode == nil,
                   let chipText = erxTasks.first(where: { $0.identifier == item.taskId })?.medication?.displayName {
                    return TimelineEntry.euEntry(item, chipTexts: [chipText])
                }
                return TimelineEntry.euEntry(item, chipTexts: [])
            })
            return timelineEntries.sorted { $0.lastUpdated > $1.lastUpdated }
        }()
    }

    var euAccessCode: EuAccessCode? {
        communications.first { $0.euAccessCode != nil }?.euAccessCode
    }

    var latestMessage: String {
        timelineEntries.first?.text ?? ""
    }

    var hasUnreadEntries: Bool {
        communications.contains { !$0.isRead }
    }
}

extension EuOrder: Comparable {
    static func <(lhs: EuOrder, rhs: EuOrder) -> Bool {
        lhs.lastUpdated > rhs.lastUpdated
    }
}
