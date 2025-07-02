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

import ComposableArchitecture
import eRpKit
import SwiftUI

extension ChargeItemListDomain {
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

        let original: ErxSparseChargeItem

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
        typealias Action = ChargeItemListDomain.Action
        let message: TextState
        let buttonText: TextState
        let action: Action

        static let authenticate: Self = .init(
            message: .init(L10n.stgTxtChargeItemListBottomBannerAuthenticateMessage),
            buttonText: .init(L10n.stgBtnChargeItemListBottomBannerAuthenticateButton),
            action: .authenticateBottomBannerButtonTapped
        )

        static let grantConsent: Self = .init(
            message: .init(L10n.stgTxtChargeItemListBottomBannerGrantMessage),
            buttonText: .init(L10n.stgBtnChargeItemListBottomBannerGrantButton),
            action: .grantConsentBottomBannerButtonTapped
        )

        static let loading: Self = .init(
            message: .init(L10n.stgTxtChargeItemListBottomBannerLoadingMessage),
            buttonText: .init(""),
            action: .nothing
        )
    }

    struct ToolbarMenuState: Equatable {
        typealias Action = ChargeItemListDomain.Action

        let entries: [Entry]

        struct Entry: Equatable, Identifiable {
            let id = UUID()
            let labelText: TextState
            let action: Action
            let a11y: String
            var destructive = false

            static let connect: Self = .init(
                labelText: .init(L10n.stgTxtChargeItemListToolbarMenuAuthenticate),
                action: .connectMenuButtonTapped,
                a11y: A11y.settings.chargeItemList.stgTxtChargeItemListMenuEntryConnect
            )
            static let activate: Self = .init(
                labelText: .init(L10n.stgTxtChargeItemListToolbarMenuGrant),
                action: .activateMenuButtonTapped,
                a11y: A11y.settings.chargeItemList.stgTxtChargeItemListMenuEntryActivate
            )
            static let deactivate: Self = .init(
                labelText: .init(L10n.stgTxtChargeItemListToolbarMenuRevoke),
                action: .deactivateMenuButtonTapped,
                a11y: A11y.settings.chargeItemList.stgTxtChargeItemListMenuEntryDeactivate,
                destructive: true
            )
        }
    }
}

extension Collection where Element == ErxSparseChargeItem {
    func asChargeItemGroups() -> [ChargeItemListDomain.ChargeItemGroup] {
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

                return ChargeItemListDomain.ChargeItem(
                    id: chargeItem.identifier,
                    description: chargeItem.medication?.name ?? "-",
                    localizedDate: formattedDate,
                    date: date,
                    flags: [], // TODO: Fill with correct flags swiftlint:disable:this todo
                    original: chargeItem
                )
            }
            let sum = value.reduce(into: 0.0) { acc, item in
                acc += (item.invoice?.totalGross.doubleValue ?? 0)
            }

            let currencyFormatter = NumberFormatter()
            currencyFormatter.numberStyle = .currency
            currencyFormatter.currencyCode = "EUR"
            currencyFormatter.locale = Locale(identifier: "DE")

            let title = key.map(String.init) ?? "Unknown"

            return ChargeItemListDomain.ChargeItemGroup(
                id: title,
                title: title,
                chargeSum: currencyFormatter.string(from: sum as NSNumber) ?? "-",
                chargeItems: items.sorted(by: <)
            )
        }
        .sorted(by: <)
    }
}
