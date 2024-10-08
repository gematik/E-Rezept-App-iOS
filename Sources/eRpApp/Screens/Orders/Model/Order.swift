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

import Dependencies
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
        let communicationTimestamp = communications.max { $0.timestamp > $1.timestamp }?.timestamp ?? ""
        if let chargeItemTimestamp = chargeItems.max(by: { $0.enteredDate ?? "" > $1.enteredDate ?? "" })?.enteredDate {
            lastUpdated = [communicationTimestamp, chargeItemTimestamp].max(by: >) ?? ""
        } else {
            lastUpdated = communicationTimestamp
        }
        tasksCount = Set(communications.map(\.taskId)).count
        timelineEntries = {
            let displayedCommunications = IdentifiedArray(uniqueElements: communications.filterUnique())
            var timelineEntries: [TimelineEntry] = displayedCommunications.compactMap { communication in
                switch communication.profile {
                case .dispReq:
                    return .dispReq(communication, pharmacy: pharmacy)
                case .reply:
                    return .reply(communication)
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

extension Order {
    enum Markdown: Equatable {
        case orderPharmacy(_ name: String)
        case phoneNumber(_ name: String)

        var link: String {
            switch self {
            case let .orderPharmacy(name):
                return "[\(name)](screen://OrderPharmacyView)"
            case let .phoneNumber(number):
                let rawNumber = number.filter { $0.isWholeNumber || $0 == "+" }
                return "[\(number)](tel:\(rawNumber))"
            }
        }
    }

    enum TimelineEntry: Equatable, Identifiable {
        case dispReq(ErxTask.Communication, pharmacy: PharmacyLocation?)
        case reply(ErxTask.Communication)
        case chargeItem(ErxChargeItem)

        var id: String {
            switch self {
            case let .dispReq(communication, _):
                return communication.identifier
            case let .reply(communication):
                return communication.identifier
            case let .chargeItem(chargeItem):
                return chargeItem.identifier
            }
        }

        var lastUpdated: String {
            switch self {
            case let .dispReq(communication, _):
                return communication.timestamp
            case let .reply(communication):
                return communication.timestamp
            case let .chargeItem(chargeItem):
                return chargeItem.enteredDate ?? ""
            }
        }

        var isRead: Bool {
            switch self {
            case let .dispReq(communication, _):
                return communication.isRead
            case let .reply(communication):
                return communication.isRead
            case let .chargeItem(chargeItem):
                return chargeItem.isRead
            }
        }

        var text: String {
            switch self {
            case let .dispReq(_, pharmacy):
                let pharmacyName = pharmacy?.name ?? L10n.ordTxtNoPharmacyName.text
                return L10n.ordDetailTxtSendTo(
                    L10n.ordDetailTxtPresc(1).text,
                    pharmacyName
                ).text
            case let .reply(communication):
                guard let payload = communication.payload else {
                    return L10n.ordDetailTxtError.text
                }
                if let text = communication.payload?.infoText, !text.isEmpty {
                    return text
                } else if !payload.isPickupCodeEmptyOrNil {
                    return L10n.ordDetailMsgsTxtOnPremise.text
                } else if payload.url != nil {
                    return L10n.ordDetailMsgsTxtUrl.text
                } else {
                    return L10n.ordDetailMsgsTxtEmpty.text
                }
            case let .chargeItem(chargeItem):
                return L10n.ordDetailTxtChargeItem(chargeItem.medication?.name ?? "").text
            }
        }

        /// Returns formatted text  (e.g. inline markdown)
        var formattedText: AttributedString {
            switch self {
            case let .dispReq(_, pharmacy):
                if let name = pharmacy?.name,
                   let formattedText = try? AttributedString(markdown: L10n.ordDetailTxtSendTo(
                       L10n.ordDetailTxtPresc(1).text,
                       Markdown.orderPharmacy(name).link
                   ).text) {
                    return formattedText
                }
                return AttributedString(text)
            case let .reply(communication):
                if let payload = communication.payload,
                   let text = payload.infoText, !text.isEmpty {
                    @Dependency(\.dataDetector) var dataDetector: DataDetector
                    // Replace all detected phone numbers with markdown links
                    var formattedText = text
                    if let numbers = try? dataDetector.phoneNumbers(text), !numbers.isEmpty {
                        for number in numbers {
                            let formattedNumber = Markdown.phoneNumber(number).link
                            formattedText = formattedText.replacingOccurrences(of: number, with: formattedNumber)
                        }
                    }
                    if let attributedText = try? AttributedString(markdown: formattedText) {
                        return attributedText
                    }
                }
                return AttributedString(text)
            case .chargeItem:
                return AttributedString(text)
            }
        }

        struct ActionEntry: Identifiable {
            let id: ActionType
            let name: String
            let action: OrderDetailDomain.Action

            enum ActionType: String {
                case loadAndShowPharmacy
                case ordDetailBtnError
                case ordDetailBtnOnPremise
                case ordDetailBtnLink
                case ordDetailBtnChargeItem
            }
        }

        var actions: IdentifiedArrayOf<ActionEntry> {
            switch self {
            case let .dispReq(_, pharmacy):
                guard let name = pharmacy?.name else {
                    return IdentifiedArray(uniqueElements: [])
                }
                return IdentifiedArray(uniqueElements: [
                    ActionEntry(id: .loadAndShowPharmacy, name: name, action: .loadAndShowPharmacy),
                ])
            case let .reply(communication):
                guard let payload = communication.payload else {
                    return IdentifiedArray(uniqueElements: [
                        ActionEntry(
                            id: .ordDetailBtnError,
                            name: L10n.ordDetailBtnError.text,
                            action: .openMail(message: communication.payloadJSON)
                        ),
                    ])
                }
                var actions: IdentifiedArrayOf<ActionEntry> = .init(uniqueElements: [])
                if !payload.isPickupCodeEmptyOrNil {
                    actions.append(ActionEntry(
                        id: .ordDetailBtnOnPremise,
                        name: L10n.ordDetailBtnOnPremise.text,
                        action: .showPickupCode(dmcCode: payload.pickUpCodeDMC, hrCode: payload.pickUpCodeHR)
                    ))
                }
                if let urlString = payload.url,
                   !urlString.isEmpty,
                   let url = URL(string: urlString) {
                    actions.append(ActionEntry(
                        id: .ordDetailBtnLink,
                        name: L10n.ordDetailBtnLink.text,
                        action: .openUrl(url: url)
                    ))
                }
                return actions
            case let .chargeItem(chargeItem):
                return IdentifiedArray(uniqueElements: [
                    ActionEntry(
                        id: .ordDetailBtnChargeItem,
                        name: L10n.ordDetailBtnChargeItem.text,
                        action: .showChargeItem(chargeItem)
                    ),
                ])
            }
        }
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
