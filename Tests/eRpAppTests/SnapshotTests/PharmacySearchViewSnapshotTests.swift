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

@testable import eRpApp
import eRpKit
import SnapshotTesting
import SwiftUI
import XCTest

final class PharmacySearchViewSnapshotTests: XCTestCase {
    var uiApplicationMock: UIApplicationOpenURLMock!

    override func setUp() {
        super.setUp()

        uiApplicationMock = UIApplicationOpenURLMock()
        diffTool = "open"
    }

    let environment = PharmacySearchDomain.Environment(
        schedulers: Schedulers(),
        pharmacyRepository: MockPharmacyRepository(),
        locationManager: .live,
        fhirDateFormatter: FHIRDateFormatter.shared,
        openHoursCalculator: PharmacyOpenHoursCalculator(),
        referenceDateForOpenHours: PharmacySearchDomainTests.TestData.openHoursTestReferenceDate,
        userSession: DummySessionContainer(),
        openURL: { _, _, _ in },
        signatureProvider: DummySecureEnclaveSignatureProvider(),
        accessibilityAnnouncementReceiver: { _ in },
        userSessionProvider: DummyUserSessionProvider()
    )

    func testPharmacySearchStartView_WithoutLocalPharmacies() {
        let sut = NavigationView {
            PharmacySearchView(
                store: PharmacySearchDomain.Store(
                    initialState: PharmacySearchDomainTests.TestData.stateWithStartView,
                    reducer: .empty,
                    environment: environment
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
                    reducer: .empty,
                    environment: environment
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
                store: storeFor(
                    state: .init(
                        erxTasks: [],
                        searchText: "Apothekesdfwerwerasdf",
                        searchState: .searchResultEmpty
                    )
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
                store: storeFor(
                    state: .init(
                        erxTasks: [],
                        searchText: "Adler Apo",
                        pharmacies: PharmacyLocationViewModel.Fixtures.pharmacies,
                        searchState: .searchResultOk
                    )
                ),
                profileSelectionToolbarItemStore: storeFor(profile: UserProfile.Dummies.profileA),
                isRedeemRecipe: false
            )
        }

        assertSnapshots(matching: sut, as: snapshotModiOnDevices())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithAccessibility())
        assertSnapshots(matching: sut, as: snapshotModiOnDevicesWithTheming())
    }

    func storeFor(state: PharmacySearchDomain.State) -> PharmacySearchDomain.Store {
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
                userSession: MockUserSession(),
                openURL: uiApplicationMock.openURL,
                signatureProvider: MockSecureEnclaveSignatureProvider(),
                accessibilityAnnouncementReceiver: { _ in },
                userSessionProvider: MockUserSessionProvider()
            )
        )
    }

    func storeFor(profile: UserProfile?) -> ProfileSelectionToolbarItemDomain.Store {
        .init(
            initialState: .init(profile: profile, profileSelectionState: .init()),
            reducer: .empty,
            environment: ProfileSelectionToolbarItemDomain.Environment(
                schedulers: Schedulers(),
                userProfileService: MockUserProfileService(),
                router: MockRouting()
            )
        )
    }
}
