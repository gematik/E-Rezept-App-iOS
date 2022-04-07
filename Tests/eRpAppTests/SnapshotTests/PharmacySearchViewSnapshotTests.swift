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

@testable import eRpApp
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class PharmacySearchViewSnapshotTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        diffTool = "open"
    }

    func testPharmacySearch() {
        let sut = NavigationView {
            PharmacySearchView(store: PharmacySearchDomain.Dummies.store)
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func testPharmacySearch_searchResultEmpty() {
        let sut = NavigationView {
            PharmacySearchView(
                store: Self.storeFor(
                    state: .init(
                        erxTasks: [],
                        searchText: "Apothekesdfwerwerasdf",
                        searchState: .searchResultEmpty
                    )
                ),
                profileSelectionToolbarItemStore: Self.storeFor(profile: UserProfile.Dummies.profileA),
                isRedeemRecipe: false
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    static func storeFor(state: PharmacySearchDomain.State) -> PharmacySearchDomain.Store {
        .init(
            initialState: state,
            reducer: .empty,
            environment: PharmacySearchDomain.Environment(
                schedulers: Schedulers(),
                pharmacyRepository: MockPharmacyRepository(),
                locationManager: .unimplemented(),
                fhirDateFormatter: FHIRDateFormatter.shared,
                openHoursCalculator: PharmacyOpenHoursCalculator(),
                referenceDateForOpenHours: Date(),
                userSession: MockUserSession()
            )
        )
    }

    static func storeFor(profile: UserProfile?) -> ProfileSelectionToolbarItemDomain.Store {
        .init(
            initialState: .init(profile: profile, profileSelectionState: .init()),
            reducer: .empty,
            environment: ProfileSelectionToolbarItemDomain.Environment(
                schedulers: Schedulers(),
                userDataStore: MockUserDataStore(),
                userProfileService: MockUserProfileService(),
                router: MockRouting()
            )
        )
    }
}
