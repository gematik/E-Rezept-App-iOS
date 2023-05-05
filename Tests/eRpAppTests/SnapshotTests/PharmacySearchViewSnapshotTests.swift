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
@testable import eRpApp
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class PharmacySearchViewSnapshotTests: XCTestCase {
    var resourceHandlerMock: MockResourceHandler!

    override func setUp() {
        super.setUp()

        resourceHandlerMock = MockResourceHandler()
        diffTool = "open"
    }

    func testPharmacySearchStartView_WithoutLocalPharmacies() {
        let sut = NavigationView {
            PharmacySearchView(
                store: PharmacySearchDomain.Store(
                    initialState: PharmacySearchDomainTests.TestData.stateWithStartView,
                    reducer: EmptyReducer()
                )
            )
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
                store: PharmacySearchDomain.Store(
                    initialState: state,
                    reducer: EmptyReducer()
                )
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
                        erxTasks: [],
                        searchText: "Apothekesdfwerwerasdf",
                        searchState: .searchResultEmpty
                    ),
                    reducer: EmptyReducer()
                ),
                profileSelectionToolbarItemStore: storeFor(profile: UserProfile.Dummies.profileA),
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
                        erxTasks: [],
                        searchText: "Adler Apo",
                        pharmacies: PharmacyLocationViewModel.Fixtures.pharmacies,
                        searchState: .searchResultOk
                    ),
                    reducer: EmptyReducer()
                ),
                profileSelectionToolbarItemStore: storeFor(profile: UserProfile.Dummies.profileA),
                isRedeemRecipe: false
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func storeFor(profile: UserProfile?) -> ProfileSelectionToolbarItemDomain.Store {
        .init(
            initialState: .init(profile: profile, profileSelectionState: .init()),
            reducer: EmptyReducer()
        )
    }
}
