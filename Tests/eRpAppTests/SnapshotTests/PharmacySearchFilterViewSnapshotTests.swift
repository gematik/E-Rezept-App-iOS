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

import ComposableArchitecture
@testable import eRpFeatures
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class PharmacySearchFilterViewSnapshotTests: ERPSnapshotTestCase {
    func testPharmacySearchFilterView_Empty() {
        let sut = NavigationStack {
            PharmacySearchFilterView(
                store: StoreOf<PharmacySearchFilterDomain>(
                    initialState: .init(pharmacyFilterOptions: Shared([PharmacySearchFilterDomain
                            .PharmacyFilterOption]()))

                ) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacySearchFilterView_SomeSelection() {
        let sut = NavigationStack {
            PharmacySearchFilterView(
                store: StoreOf<PharmacySearchFilterDomain>(
                    initialState: .init(pharmacyFilterOptions: Shared([
                        PharmacySearchFilterDomain.PharmacyFilterOption.currentLocation,
                        PharmacySearchFilterDomain.PharmacyFilterOption.shipment,
                    ]))

                ) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
