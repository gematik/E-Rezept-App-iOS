//
//  Copyright (c) 2021 gematik GmbH
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
@testable import eRpApp
import eRpKit
import Nimble
import Pharmacy
import XCTest

class PharmacySearchTests: XCTestCase {
    let testScheduler = DispatchQueue.test
    typealias TestStore = ComposableArchitecture.TestStore<
        PharmacySearchDomain.State,
        PharmacySearchDomain.State,
        PharmacySearchDomain.Action,
        PharmacySearchDomain.Action,
        PharmacySearchDomain.Environment
    >
    var store: TestStore!
    // For tests we can lower the delay for search start
    var delaySearchStart: DispatchQueue.SchedulerTimeType.Stride = 0.1

    override func tearDownWithError() throws {
        store = nil

        try super.tearDownWithError()
    }

    func testStore() -> TestStore {
        testStore(for: TestData.stateEmpty)
    }

    func testStore(for state: PharmacySearchDomain.State) -> TestStore {
        TestStore(
            initialState: state,
            reducer: PharmacySearchDomain.reducer,
            environment: PharmacySearchDomain.Environment(
                schedulers: Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler()),
                pharmacyRepository: MockPharmacyRepository(),
                locationManager: .unimplemented(),
                fhirDateFormatter: FHIRDateFormatter.shared,
                openHoursCalculator: PharmacyOpenHoursCalculator(),
                referenceDateForOpenHours: TestData.openHoursTestReferenceDate
            )
        )
    }

    func testSearchForPharmacies() {
        // given
        store = testStore(for: TestData.state)
        let testSearchText = "Apo"
        let expected: Result<[PharmacyLocation], PharmacyRepositoryError> = .success(TestData.pharmacies)
        let expectedSorted: [PharmacyLocationViewModel] =
            TestData.pharmaciesSortedAlphabetical.map {
                PharmacyLocationViewModel(
                    pharmacy: $0,
                    referenceLocation: nil,
                    referenceDate: TestData.openHoursTestReferenceDate
                )
            }

        store.assert(
            // when search text changes to valid search term...
            .send(.searchTextChanged(testSearchText)) { state in
                // ...expect it to be stored
                state.searchText = testSearchText
            },
            // when user hits Enter on keyboard start search...
            .send(.performSearch) { state in
                // ...expect a search request to run
                state.searchState = .searchRunning
            },
            .do { self.testScheduler.advance() },
            // when search request is done...
            .receive(.pharmaciesReceived(expected)) { state in
                // expect it to deliver successful & results...
                state.searchState = .searchResultOk(
                    try expected.get().map {
                        PharmacyLocationViewModel(
                            pharmacy: $0,
                            referenceLocation: nil,
                            referenceDate: TestData.openHoursTestReferenceDate
                        )
                    }
                )
            },
            .receive(.sortedResultReceived(expectedSorted)) { state in
                state.pharmacies = expectedSorted
            }
        )
    }

    func testSearchForPharmaciesEmptyResult() {
        // given
        store = testStore()
        let testSearchText = "Apodfdfd"
        let expected: Result<[PharmacyLocation], PharmacyRepositoryError> = .success([])

        store.assert(
            // when search text changes to valid search term...
            .send(.searchTextChanged(testSearchText)) { state in
                // ...expect it to be stored
                state.searchText = testSearchText
            },
            // when user hits Enter on keyboard start search...
            .send(.performSearch) { state in
                // ...expect a search request to run
                state.searchState = .searchRunning
            },
            .do { self.testScheduler.advance() },
            // when search request is done...
            .receive(.pharmaciesReceived(expected)) { state in
                // expect it to be empty...
                state.searchState = .searchResultEmpty
            }
        )
    }

    func testSearchForPharmaciesWithLocation() {
        // given
        store = testStore(for: TestData.stateWithLocation)
        let expected: Result<[PharmacyLocation], PharmacyRepositoryError> = .success(TestData.pharmaciesWithLocations)
        let expectedSorted: [PharmacyLocationViewModel] =
            TestData.pharmaciesWithLocations.map {
                PharmacyLocationViewModel(
                    pharmacy: $0,
                    referenceLocation: TestData.stateWithLocation.currentLocation,
                    referenceDate: TestData.openHoursTestReferenceDate
                )
            }

        store.assert(
            // when user hits Location button start search...
            .send(.performSearch) { state in
                // ...expect a search request to run
                state.sortOrder = .distance
                state.searchState = .searchRunning
            },
            .do { self.testScheduler.advance() },
            // when search request is done...
            .receive(.pharmaciesReceived(expected)) { state in
                // expect it to deliver successful & results...
                state.searchState = .searchResultOk(
                    try expected.get().map {
                        PharmacyLocationViewModel(
                            pharmacy: $0,
                            referenceLocation: state.currentLocation,
                            referenceDate: TestData.openHoursTestReferenceDate
                        )
                    }
                )
            },
            .receive(.sortedResultReceived(expectedSorted)) { state in
                state.pharmacies = expectedSorted
            }
        )
    }
}

extension PharmacySearchTests {
    /// Test-Data values for `PharmacyLocation`
    public enum TestData {
        /// Test-Date for opening/closing state
        public static var openHoursTestReferenceDate: Date? {
            // Current dummy-time is set to 10:00am on 16th (WED) June 2021...
            var dateComponents = DateComponents()
            dateComponents.year = 2021
            dateComponents.month = 6
            dateComponents.day = 16
            dateComponents.timeZone = TimeZone.current
            dateComponents.hour = 10
            dateComponents.minute = 00
            let cal = Calendar(identifier: .gregorian)
            return cal.date(from: dateComponents)
        }

        /// Test-Data PharmacyDomain.State
        public static let state =
            PharmacySearchDomain.State(
                erxTasks: [ErxTask.Dummies.prescription],
                searchText: "",
                pharmacies: pharmacies.map { pharmacies in
                    PharmacyLocationViewModel(
                        pharmacy: pharmacies,
                        referenceLocation: nil,
                        referenceDate: TestData.openHoursTestReferenceDate
                    )
                }
            )
        /// Test-Data PharmacyDomain.State
        public static let stateEmpty =
            PharmacySearchDomain.State(
                erxTasks: [ErxTask.Dummies.prescription],
                searchText: "",
                pharmacies: []
            )
        /// Test-Data PharmacyDomain.State with a location
        public static let stateWithLocation =
            PharmacySearchDomain.State(
                erxTasks: [ErxTask.Dummies.prescription],
                searchText: "",
                currentLocation: testLocation,
                pharmacies: pharmaciesWithLocations.map { pharmacies in
                    PharmacyLocationViewModel(
                        pharmacy: pharmacies,
                        referenceLocation: testLocation,
                        referenceDate: openHoursTestReferenceDate
                    )
                }
            )
        /// Test location
        public static let testLocation = Location(
            rawValue: CLLocation(latitude: 49.2470345, longitude: 8.8668786)
        )
        /// Test-Data address
        public static let address1 = PharmacyLocation.Address(
            street: "Hinter der Bahn",
            houseNumber: "6",
            zip: "12345",
            city: "Buxtehude"
        )
        /// Test-Data address
        public static let address2 = PharmacyLocation.Address(
            street: "Meisenweg",
            houseNumber: "23",
            zip: "54321",
            city: "Linsengericht"
        )
        /// Test-Data telecom
        public static let telecom = PharmacyLocation.Telecom(
            phone: "555-Schuh",
            fax: "555-123456",
            email: "info@gematik.de",
            web: "http://www.gematik.de"
        )
        /// Test-Data Pharmacy 1
        public static let pharmacy1 = PharmacyLocation(
            id: "1",
            status: .active,
            telematikID: "3-06.2.ycl.123",
            name: "Apotheke am Wäldchen",
            types: [.pharm, .emergency, .mobl, .outpharm],
            position: PharmacyLocation.Position(
                latitude: Decimal(testLocation.coordinate.latitude),
                longitude: Decimal(testLocation.coordinate.longitude)
            ),
            address: address1,
            telecom: telecom,
            hoursOfOperation: [
                PharmacyLocation.HoursOfOperation(
                    daysOfWeek: ["mon", "tue"],
                    openingTime: "08:00:00",
                    closingTime: "07:00:00"
                ),
            ]
        )
        /// Test-Data Pharmacy 2
        public static let pharmacy2 = PharmacyLocation(
            id: "2",
            status: .inactive,
            telematikID: "3-09.2.S.10.124",
            name: "Apotheke hinter der Bahn",
            types: [PharmacyLocation.PharmacyType.pharm,
                    PharmacyLocation.PharmacyType.outpharm],
            address: address2,
            telecom: telecom,
            hoursOfOperation: [
                PharmacyLocation.HoursOfOperation(
                    daysOfWeek: ["wed"],
                    openingTime: "08:00:00",
                    closingTime: "07:00:00"
                ),
            ]
        )
        /// Test-Data Pharmacy 3
        public static let pharmacy3 = PharmacyLocation(
            id: "3",
            status: .active,
            telematikID: "3-09.2.sdf.125",
            name: "Apotheke Elise mit langem Vor- und Zunamen am Rathaus",
            types: [PharmacyLocation.PharmacyType.pharm,
                    PharmacyLocation.PharmacyType.mobl],
            address: address1,
            telecom: telecom,
            hoursOfOperation: []
        )
        /// Test-Data Pharmacy 4
        public static let pharmacy4 = PharmacyLocation(
            id: "4",
            status: .inactive,
            telematikID: "3-09.2.dfs.126",
            name: "Eulenapotheke",
            types: [PharmacyLocation.PharmacyType.outpharm],
            address: address2,
            telecom: telecom,
            hoursOfOperation: [
                PharmacyLocation.HoursOfOperation(
                    daysOfWeek: ["fri"],
                    openingTime: "07:00:00",
                    closingTime: "13:00:00"
                ),
            ]
        )

        /// Test-Data arry of pharmacies
        public static let pharmacies = [
            pharmacy1,
            pharmacy2,
            pharmacy3,
            pharmacy4,
        ]
        /// Test-Data array of pharmacies sorted alphabetical
        public static let pharmaciesSortedAlphabetical = [
            pharmacy1,
            pharmacy3,
            pharmacy2,
            pharmacy4,
        ]
        /// Test-Data array of pharmacies with a location
        public static let pharmaciesWithLocations = [
            pharmacy1,
        ]
    }
}
