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
import UIKit

enum TimelineEntry: Equatable, Identifiable {
    case dispReq(ErxTask.Communication.Unique, pharmacy: PharmacyLocation?, chipTexts: [String])
    case reply(ErxTask.Communication.Unique, chipTexts: [String])
    case chargeItem(ErxChargeItem)
    case internalCommunication(InternalCommunication.Message)

    var id: String {
        switch self {
        case let .dispReq(communication, _, _):
            return communication.identifier
        case let .reply(communication, _):
            return communication.identifier
        case let .chargeItem(chargeItem):
            return chargeItem.identifier
        case let .internalCommunication(message):
            return message.id
        }
    }

    var lastUpdated: String {
        switch self {
        case let .dispReq(communication, _, _):
            return communication.timestamp
        case let .reply(communication, _):
            return communication.timestamp
        case let .chargeItem(chargeItem):
            return chargeItem.enteredDate ?? ""
        case let .internalCommunication(message):
            // Temporary convert the Date to a String, will be removed when 'lastUpdated: Date'
            return dateToString(date: message.timestamp)
        }
    }

    var isRead: Bool {
        switch self {
        case let .dispReq(communication, _, _):
            return communication.isRead
        case let .reply(communication, _):
            return communication.isRead
        case let .chargeItem(chargeItem):
            return chargeItem.isRead
        case let .internalCommunication(message):
            return message.isRead
        }
    }

    var text: String {
        switch self {
        case let .dispReq(_, pharmacy, _):
            let pharmacyName = pharmacy?.name ?? L10n.ordTxtNoPharmacyName.text
            return L10n.ordDetailTxtSendTo(
                L10n.ordDetailTxtPresc(1).text,
                pharmacyName
            ).text
        case let .reply(communication, _):
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
        case let .internalCommunication(message):
            return message.text
        }
    }

    /// Returns formatted text  (e.g. inline markdown)
    var formattedText: AttributedString {
        switch self {
        case let .dispReq(_, pharmacy, _):
            if let name = pharmacy?.name,
               let formattedText = try? AttributedString(markdown: L10n.ordDetailTxtSendTo(
                   L10n.ordDetailTxtPresc(1).text,
                   Markdown.orderPharmacy(name).link
               ).text) {
                return formattedText
            }
            return AttributedString(text)
        case let .reply(communication, _):
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
        case .internalCommunication:
            if let attributedString = try? AttributedString(
                markdown: text,
                options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            ), id != "1" {
                let paragraphStyle = NSMutableParagraphStyle()
                let text = NSMutableAttributedString(attributedString)
                text.enumerateAttributes(in: NSRange(location: 0, length: text.length),
                                         options: [.reverse]) { attributes, range, _ in
                    var newAttributes = attributes
                    if let presentationIntents = attributes[.presentationIntentAttributeName] as? PresentationIntent {
                        var insertThingy = ""
                        for presentationIntent in presentationIntents.components {
                            switch presentationIntent.kind {
                            case .paragraph:
                                break
                            case .orderedList:
                                break
                            case .unorderedList:
                                insertThingy = "\n-. "
                                paragraphStyle.firstLineHeadIndent = 10.0
                                paragraphStyle.headIndent = 28.5

                                newAttributes[.paragraphStyle] = paragraphStyle
                            case let .listItem(ordinal: index):
                                // For formatting the first listItem needs two \n
                                if index == 1 {
                                    insertThingy = "\n\n\(index). "
                                } else {
                                    insertThingy = "\n\(index). "
                                }
                                // 1. Zeile
                                paragraphStyle.firstLineHeadIndent = 10.0
                                // n. Zeile
                                paragraphStyle.headIndent = 28.5

                                paragraphStyle.paragraphSpacingBefore = 0.0
                                paragraphStyle.paragraphSpacing = 0.0
                                paragraphStyle.lineBreakMode = .byWordWrapping
                                paragraphStyle
                                    .tabStops = [NSTextTab(textAlignment: .left, location: 20.0, options: [:])]

                                newAttributes[.paragraphStyle] = paragraphStyle
                            default:
                                break
                            }
                        }
                        text.insert(NSAttributedString(string: insertThingy), at: range.location)
                        text.setAttributes(
                            newAttributes,
                            range: NSRange(location: range.location, length: range.length + insertThingy.count)
                        )
                    }
                }
                return AttributedString(text)
            }
            return AttributedString(text)
        }
    }

    var chipTexts: [String] {
        switch self {
        case let .dispReq(_, _, text): return text
        case let .reply(_, text): return text
        case let .chargeItem(chargeItem):
            guard let displayName = chargeItem.medication?.displayName else { return [] }
            return [displayName]
        case let .internalCommunication(message):
            let chipText: String
            if message.version == "0.0.0" {
                // The welcome message has a static chip text
                chipText = L10n.internMsgWelcomeChip.text
            } else {
                chipText = L10n.internMsgChangeLogChip(message.version).text
            }
            return [chipText]
        }
    }

    struct ActionEntry: Identifiable {
        let id: ActionType
        let name: String
        let action: OrderDetailDomain.Action

        var accessibilityIdentifier: String {
            switch id {
            case .ordDetailBtnOnPremise:
                return A11y.orderDetail.list.ordDetailBtnDmc
            case .ordDetailBtnLink:
                return A11y.orderDetail.list.ordDetailBtnLink
            case .loadAndShowPharmacy,
                 .ordDetailBtnError,
                 .ordDetailBtnChargeItem:
                return ""
            }
        }

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
        case let .dispReq(_, pharmacy, _):
            guard let name = pharmacy?.name else {
                return IdentifiedArray(uniqueElements: [])
            }
            return IdentifiedArray(uniqueElements: [
                ActionEntry(id: .loadAndShowPharmacy, name: name, action: .loadAndShowPharmacy),
            ])
        case let .reply(communication, _):
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
        case .internalCommunication:
            return IdentifiedArray(uniqueElements: [])
        }
    }
}

extension TimelineEntry {
    struct Timeline<T> {
        let value: T
        let name: String
    }

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

    func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxx"
        return formatter.string(from: date)
    }
}
