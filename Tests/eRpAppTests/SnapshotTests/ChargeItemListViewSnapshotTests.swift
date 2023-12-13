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

import CombineSchedulers
import ComposableArchitecture
@testable import eRpApp
import IDP
import SnapshotTesting
import SwiftUI
import XCTest

final class ChargeItemListViewSnapshotTests: ERPSnapshotTestCase {
    override func setUp() {
        super.setUp()

        diffTool = "open"
    }

    let testProfileId = UUID()

    func testChargeItemListView_emptyChargeItemsList() {
        let sut = NavigationView {
            ChargeItemListView(
                store: .init(
                    initialState: .init(
                        profileId: testProfileId,
                        chargeItemGroups: [ChargeItemListDomain.ChargeItemGroup](),
                        bottomBannerState: nil
                    )

                ) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testChargeItemListView_emptyChargeItemsListAndConsentBanner() {
        let sut = NavigationView {
            ChargeItemListView(
                store: .init(
                    initialState: .init(
                        profileId: testProfileId,
                        chargeItemGroups: [ChargeItemListDomain.ChargeItemGroup](),
                        bottomBannerState: .grantConsent
                    )

                ) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testChargeItemListView_listOfChargeItems() {
        let sut = NavigationView {
            ChargeItemListView(
                store: .init(
                    initialState: .init(
                        profileId: testProfileId,
                        chargeItemGroups: [
                            ChargeItemListDomain.ChargeItemGroup.Fixtures.chargeItemGroup1,
                            ChargeItemListDomain.ChargeItemGroup.Fixtures.chargeItemGroup2,
                        ],
                        bottomBannerState: .grantConsent
                    )

                ) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}