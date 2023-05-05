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

import ComposableArchitecture
import eRpKit
import SwiftUI

extension ChargeItemsDomain {
    struct ChargeItemGroup: Equatable, Identifiable, Comparable {
        let id: String

        let title: String
        let chargeSum: String

        let chargeItems: [ChargeItem]

        static func <(lhs: Self, rhs: Self) -> Bool {
            lhs.title.compare(rhs.title, options: .numeric) == .orderedAscending
        }
    }

    struct ChargeItem: Equatable, Identifiable, Comparable {
        let id: String

        let description: String
        let localizedDate: String
        var date: Date?
        let flags: [String]

        let original: ErxChargeItem

        static func <(lhs: Self, rhs: Self) -> Bool {
            if let lhsDate = lhs.date,
               let rhsDate = rhs.date {
                return lhsDate < rhsDate
            } else if lhs.date == nil {
                return false
            }
            return true
        }
    }

    struct BottomBannerState: Equatable {
        typealias Action = ChargeItemsDomain.Action
        let message: TextState
        let buttonText: TextState
        let action: Action
        var loading = false

        static let authenticate: Self = .init(
            message: .init(L10n.stgTxtChargeItemsBottomBannerAuthenticateMessage),
            buttonText: .init(L10n.stgBtnChargeItemsBottomBannerAuthenticateButton),
            action: .authenticateBottomBannerButtonTapped
        )

        static let grantConsent: Self = .init(
            message: .init(L10n.stgTxtChargeItemsBottomBannerGrantMessage),
            buttonText: .init(L10n.stgBtnChargeItemsBottomBannerGrantButton),
            action: .grantConsentBottomBannerButtonTapped
        )

        static let loading: Self = .init(
            message: .init(L10n.stgTxtChargeItemsBottomBannerLoadingMessage),
            buttonText: .init(""),
            action: .nothing
        )
    }

    struct ToolbarMenuState: Equatable {
        typealias Action = ChargeItemsDomain.Action

        let entries: [Entry]

        struct Entry: Equatable, Identifiable {
            let id = UUID()
            let labelText: TextState
            let action: Action
            let a11y: String
            let isDisabled: Bool
            var destructive = false

            var disabled: Self {
                if isDisabled { return self }
                return .init(
                    labelText: labelText,
                    action: action,
                    a11y: a11y,
                    isDisabled: true
                )
            }

            static let connect: Self = .init(
                labelText: .init(L10n.stgTxtChargeItemsToolbarMenuAuthenticate),
                action: .connectMenuButtonTapped,
                a11y: A11y.settings.chargeItems.stgTxtChargeItemsMenuEntryConnect,
                isDisabled: false
            )
            static let activate: Self = .init(
                labelText: .init(L10n.stgTxtChargeItemsToolbarMenuGrant),
                action: .activateMenuButtonTapped,
                a11y: A11y.settings.chargeItems.stgTxtChargeItemsMenuEntryActivate,
                isDisabled: false
            )
            static let deactivate: Self = .init(
                labelText: .init(L10n.stgTxtChargeItemsToolbarMenuRevoke),
                action: .deactivateMenuButtonTapped,
                a11y: A11y.settings.chargeItems.stgTxtChargeItemsMenuEntryDeactivate,
                isDisabled: false,
                destructive: true
            )
        }
    }
}

extension Collection where Element == ErxChargeItem {
    func asChargeItemGroups() -> [ChargeItemsDomain.ChargeItemGroup] {
        @Dependency(\.uiDateFormatter) var dateFormatter
        @Dependency(\.fhirDateFormatter) var fhirDateFormatter

        let chargeItemGroups = Dictionary(grouping: self) { chargeItem -> Int? in
            guard let enteredDate = chargeItem.enteredDate,
                  let date = fhirDateFormatter.date(from: enteredDate) else {
                return nil
            }
            let components = Calendar.current.dateComponents([.year], from: date)
            return components.year
        }

        return chargeItemGroups.map { key, value in
            let items = value.map { chargeItem in
                let date = fhirDateFormatter.date(from: chargeItem.enteredDate ?? "")
                let formattedDate = date.map { dateFormatter.relativeDate(from: $0) } ?? "-"

                return ChargeItemsDomain.ChargeItem(
                    id: chargeItem.identifier,
                    description: chargeItem.medicationText,
                    localizedDate: formattedDate,
                    date: date,
                    flags: [], // TODO: Fill with correct flags swiftlint:disable:this todo
                    original: chargeItem
                )
            }
            let sum = value.reduce(into: 123) { _, _ in
                // TODO: add costs * 100 swiftlint:disable:this todo
            }

            let currencyFormatter = NumberFormatter()
            currencyFormatter.numberStyle = .currency
            currencyFormatter.currencyCode = "EUR"
            currencyFormatter.locale = Locale(identifier: "DE")

            let title = key.map(String.init) ?? "Unkown"

            return ChargeItemsDomain.ChargeItemGroup(
                id: title,
                title: title,
                chargeSum: currencyFormatter.string(from: sum as NSNumber) ?? "-",
                chargeItems: items.sorted(by: <)
            )
        }
        .sorted(by: <)
    }
}
