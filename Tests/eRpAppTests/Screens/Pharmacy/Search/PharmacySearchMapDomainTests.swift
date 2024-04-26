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
import Combine
import ComposableArchitecture
import ComposableCoreLocation
@testable import eRpApp
import eRpKit
import MapKit
import Nimble
import Pharmacy
import XCTest

@MainActor
class PharmacySearchMapDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = TestStoreOf<PharmacySearchMapDomain>

    var resourceHandlerMock: MockResourceHandler!
    var searchHistoryMock: MockSearchHistory!

    override func setUp() {
        super.setUp()

        resourceHandlerMock = MockResourceHandler()
        searchHistoryMock = MockSearchHistory()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testStore(
        for state: PharmacySearchMapDomain.State,
        pharmacyRepository: PharmacyRepository = MockPharmacyRepository()
    ) -> TestStore {
        TestStore(initialState: state) {
            PharmacySearchMapDomain(referenceDateForOpenHours: TestData.openHoursTestReferenceDate)
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.pharmacyRepository = pharmacyRepository
            dependencies.locationManager = .failing
            dependencies.resourceHandler = resourceHandlerMock
        }
    }

    func testSearchForPharmacies() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo.searchRemoteSearchTermPositionFilterReturnValue = Just(TestData.pharmacies)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: TestData.stateWithNoLocation, pharmacyRepository: mockPharmacyRepo)
        let expected: Result<[PharmacyLocation], PharmacyRepositoryError> = .success(TestData.pharmacies)

        await sut.send(.performSearch)
        await testScheduler.advance()
        await sut.receive(.response(.pharmaciesReceived(expected))) { state in
            state.mapLocation = MKCoordinateRegion(center: state.mapLocation.center,
                                                   span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }
    }

    func test_SearchMapWithPermission() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo.searchRemoteSearchTermPositionFilterReturnValue = Just(TestData.pharmacies)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: TestData.stateWithNoLocation, pharmacyRepository: mockPharmacyRepo)
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        sut.dependencies.locationManager.authorizationStatus = { .notDetermined }
        sut.dependencies.locationManager.delegate = { .publisher(locationManagerSubject.eraseToAnyPublisher) }
        sut.dependencies.locationManager.locationServicesEnabled = { true }

        sut.dependencies.locationManager.requestWhenInUseAuthorization = { .run { _ in } }
        sut.dependencies.locationManager.startUpdatingLocation = { .run { _ in } }
        sut.dependencies.locationManager.stopUpdatingLocation = { .run { _ in } }

        await sut.send(.onAppear)
        await sut.receive(.searchWithMap)
        await sut.receive(.requestLocation)

        locationManagerSubject.send(.didChangeAuthorization(.authorizedWhenInUse))
        await sut.receive(.locationManager(.didChangeAuthorization(.authorizedWhenInUse)))
        locationManagerSubject.send(completion: .finished)

        locationManagerSubject.send(.didUpdateLocations([TestData.testLocation]))
        await sut.send(.locationManager(.didUpdateLocations([TestData.testLocation]))) { state in
            state.currentUserLocation = TestData.testLocation
        }
        locationManagerSubject.send(completion: .finished)

        await sut.send(.goToUser) { state in
            state.mapLocation = MKCoordinateRegion(center: TestData.testLocation.coordinate,
                                                   span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }
    }

    func test_MapSearchWithoutPermission() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository()
        mockPharmacyRepo.searchRemoteSearchTermPositionFilterReturnValue = Just(TestData.pharmacies)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()

        let sut = testStore(for: TestData.stateWithWithLocation, pharmacyRepository: mockPharmacyRepo)
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        sut.dependencies.locationManager.authorizationStatus = { .denied }
        sut.dependencies.locationManager.delegate = { .publisher(locationManagerSubject.eraseToAnyPublisher) }

        await sut.send(.requestLocation) { state in
            state.currentUserLocation = nil
            state.destination = .alert(PharmacySearchMapDomain.locationPermissionAlertState)
        }

        await sut.send(.destination(.presented(.alert(.close)))) { state in
            state.destination = nil
        }

        await sut.send(.goToUser)

        await sut.receive(.requestLocation) { state in
            state.destination = .alert(PharmacySearchMapDomain.locationPermissionAlertState)
        }
    }
}

extension PharmacySearchMapDomainTests {
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
        public static let stateWithNoLocation =
            PharmacySearchMapDomain.State(
                erxTasks: [ErxTask.Fixtures.erxTaskReady],
                mapLocation: MKCoordinateRegion.gematikHQRegion,
                pharmacies: pharmacies.map { pharmacies in
                    PharmacyLocationViewModel(
                        pharmacy: pharmacies,
                        referenceLocation: nil,
                        referenceDate: TestData.openHoursTestReferenceDate
                    )
                }
            )
        /// Test-Data PharmacyDomain.State
        public static let stateWithWithLocation =
            PharmacySearchMapDomain.State(
                erxTasks: [ErxTask.Fixtures.erxTaskReady],
                mapLocation: TestData.testMapLocation,
                pharmacies: pharmacies.map { pharmacies in
                    PharmacyLocationViewModel(
                        pharmacy: pharmacies,
                        referenceLocation: nil,
                        referenceDate: TestData.openHoursTestReferenceDate
                    )
                }
            )
        /// Test location
        public static let testLocation = Location(
            rawValue: CLLocation(latitude: 49.2470345, longitude: 8.8668786)
        )
        /// Test Maplocation
        public static let testMapLocation = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 49.2470345, longitude: 8.8668786),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
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
            isFavorite: true,
            hoursOfOperation: [
                PharmacyLocation.HoursOfOperation(
                    daysOfWeek: ["mon", "tue"],
                    openingTime: "08:00:00",
                    closingTime: "12:00:00"
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
                    closingTime: "12:00:00"
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
            isFavorite: false,
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
    }
}
