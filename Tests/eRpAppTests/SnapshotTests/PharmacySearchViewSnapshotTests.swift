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
    func testPharmacySearchStartView_WithoutLocalPharmacies() {
        let sut = NavigationStack {
            PharmacySearchView(
                store: StoreOf<PharmacySearchDomain>(
                    initialState: PharmacySearchDomainTests.TestData.stateWithStartView
                ) {
                    EmptyReducer()
                }
            )
            .navigationTitle("Redeem")
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
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
            selectedPrescriptions: Shared([]),
            inRedeemProcess: false,
            searchText: "",
            pharmacies: pharmacies,
            localPharmacies: pharmacies,
            pharmacyFilterOptions: Shared([]),
            searchState: .startView(loading: false)
        )
        let sut = NavigationStack {
            PharmacySearchView(
                store: StoreOf<PharmacySearchDomain>(initialState: state) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacySearch_searchResultEmpty() {
        let sut = NavigationStack {
            PharmacySearchView(
                store: .init(
                    initialState: PharmacySearchDomain.State(
                        selectedPrescriptions: Shared([]),
                        inRedeemProcess: false,
                        searchText: "Apothekesdfwerwerasdf",
                        pharmacyFilterOptions: PharmacySearchMapDomainTests.Fixtures.sharedEmptyFilter,
                        searchState: .searchResultEmpty
                    )
                ) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacySearch_searchResultSuccess() {
        let sut = NavigationStack {
            PharmacySearchView(
                store: .init(
                    initialState: PharmacySearchDomain.State(
                        selectedPrescriptions: Shared([]),
                        inRedeemProcess: false,
                        searchText: "Adler Apo",
                        pharmacies: PharmacyLocationViewModel.Fixtures.pharmacies,
                        pharmacyFilterOptions: PharmacySearchMapDomainTests.Fixtures.sharedEmptyFilter,
                        searchState: .searchResultOk
                    )
                ) {
                    EmptyReducer()
                }
            )
        }

        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacySearch_mapSearch_WithUserButton() {
        let sut = PharmacySearchMapView(
            store: .init(
                initialState: PharmacySearchMapDomain.State(
                    selectedPrescriptions: Shared([]),
                    inRedeemProcess: false,
                    mapLocation: .manual(MKCoordinateRegion.gematikHQRegion),
                    pharmacies: PharmacyLocationViewModel.Fixtures.pharmacies,
                    pharmacyFilterOptions: PharmacySearchMapDomainTests.Fixtures.sharedEmptyFilter
                )
            ) {
                EmptyReducer()
            }
        )
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacySearch_mapSearch_ClusterView() {
        let sut = PharmacySearchMapView.ClusterView(
            store: .init(
                initialState: .init(
                    clusterPharmacies: PharmacyLocationViewModel.Fixtures.pharmacies
                )
            ) {
                EmptyReducer()
            }
        )
        assertSnapshots(of: sut, as: snapshotModiOnDevices())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(of: sut, as: snapshotModiOnDevicesWithTheming())
    }
}

extension PharmacySearchMapDomainTests {
    enum Fixtures {
        static let sharedEmptyFilter: Shared<[PharmacySearchFilterDomain.PharmacyFilterOption]> = Shared([])
    }
}
