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

import Combine
import ComposableArchitecture
import eRpKit
import Foundation
import Pharmacy

enum CommunicationMessage: Identifiable, Equatable {
    case order(Order)
    case internalCommunication(InternalCommunication)

    var id: String {
        switch self {
        case let .order(order):
            return order.id
        case let .internalCommunication(message):
            return message.id
        }
    }

    var title: String {
        switch self {
        case let .order(order):
            return order.pharmacy?.name ?? L10n.ordTxtNoPharmacyName.text
        case let .internalCommunication(message):
            return message.sender
        }
    }

    var timelineEntries: [TimelineEntry] {
        switch self {
        case let .order(order):
            return order.timelineEntries
        case let .internalCommunication(message):
            return message.messages.compactMap { message in
                TimelineEntry.internalCommunication(message)
            }
        }
    }

    var latestMessage: AttributedString {
        switch self {
        case let .order(order):
            return AttributedString(order.latestMessage)
        case let .internalCommunication(message):
            if let attributedText = try? AttributedString(markdown: message.latestMessage) {
                return attributedText
            }
            return AttributedString(message.latestMessage)
        }
    }

    var order: Order? {
        switch self {
        case let .order(order):
            return order
        case .internalCommunication:
            return nil
        }
    }

    var lastUpdated: String {
        switch self {
        case let .order(order):
            return order.lastUpdated
        case let .internalCommunication(message):
            return message.latestUpdate?.fhirFormattedString(with: .yearMonthDayTimeMilliSeconds) ?? ""
        }
    }

    var hasUnreadMessages: Bool {
        switch self {
        case let .order(order):
            return order.hasUnreadEntries
        case let .internalCommunication(message):
            return message.hasUnreadMessages
        }
    }
}
