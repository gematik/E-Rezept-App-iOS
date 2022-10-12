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

import CombineSchedulers
@testable import eRpApp
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class OrdersViewSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        diffTool = "open"
    }

    private func profileStore(for profile: UserProfile? = nil) -> ProfileSelectionToolbarItemDomain.Store {
        ProfileSelectionToolbarItemDomain.Store(
            initialState: .init(
                profile: profile ?? UserProfile.Fixtures.theo,
                profileSelectionState: .init(
                    profiles: [],
                    selectedProfileId: nil,
                    route: nil
                )
            ),
            reducer: .empty,
            environment: ProfileSelectionToolbarItemDomain.Dummies.environment
        )
    }

    func testEmptyOdersView() {
        let sut = OrdersView(store: OrdersDomain.Dummies.storeFor(OrdersDomain.State(orders: [])),
                             profileSelectionToolbarItemStore: profileStore())
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testOdersView() {
        let sut = OrdersView(store: OrdersDomain.Dummies.store,
                             profileSelectionToolbarItemStore: profileStore())
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
