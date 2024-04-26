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
import ComposableCoreLocation
@testable import eRpFeatures
import eRpKit
import MapKit
import SnapshotTesting
import SwiftUI
import XCTest

final class PharmacySearchViewSnapshotTests: ERPSnapshotTestCase {
    var resourceHandlerMock: MockResourceHandler!

    override func setUp() {
        super.setUp()

        SnapshotHelper.fixOffsetProblem()

        resourceHandlerMock = MockResourceHandler()
        diffTool = "open"
    }

    func testPharmacySearchStartView_WithoutLocalPharmacies() {
        let sut = NavigationView {
            PharmacySearchView(
                store: PharmacySearchDomain.Store(
                    initialState: PharmacySearchDomainTests.TestData.stateWithStartView
                ) {
                    EmptyReducer()
                }
            )
            .navigationTitle("Redeem")
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacySearchStartView_WithLocalPharmacies() {
        let pharmacies = PharmacySearchDomainTests.TestData.pharmacies.map { pharmacies in
            PharmacyLocationViewModel(
                pharmacy: pharmacies,
                referenceLocation: nil,
                referenceDate: PharmacySearchDomainTests.TestData.openHoursTestReferenceDate
            )
        }
        let state = PharmacySearchDomain.State(
            erxTasks: [ErxTask.Fixtures.erxTaskReady],
            searchText: "",
            pharmacies: pharmacies,
            localPharmacies: pharmacies,
            searchState: .startView(loading: false)
        )
        let sut = NavigationView {
            PharmacySearchView(
                store: PharmacySearchDomain.Store(initialState: state) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacySearch_searchResultEmpty() {
        let sut = NavigationView {
            PharmacySearchView(
                store: .init(
                    initialState: .init(
                        erxTasks: [ErxTask](),
                        searchText: "Apothekesdfwerwerasdf",
                        searchState: .searchResultEmpty
                    )
                ) {
                    EmptyReducer()
                },

                isRedeemRecipe: false
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacySearch_searchResultSuccess() {
        let sut = NavigationView {
            PharmacySearchView(
                store: .init(
                    initialState: .init(
                        erxTasks: [ErxTask](),
                        searchText: "Adler Apo",
                        pharmacies: PharmacyLocationViewModel.Fixtures.pharmacies,
                        searchState: .searchResultOk
                    )
                ) {
                    EmptyReducer()
                },

                isRedeemRecipe: false
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacySearch_mapSearch_WithUserButton() {
        let sut = PharmacySearchMapView(
            store: .init(
                initialState: .init(
                    erxTasks: [ErxTask](),
                    mapLocation: .manual(MKCoordinateRegion.gematikHQRegion),
                    pharmacies: PharmacyLocationViewModel.Fixtures.pharmacies
                )
            ) {
                EmptyReducer()
            },

            isRedeemRecipe: false
        )
        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }
}
