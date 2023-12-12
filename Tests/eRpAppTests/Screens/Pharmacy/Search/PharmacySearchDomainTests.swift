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
import Combine
import ComposableArchitecture
import ComposableCoreLocation
@testable import eRpApp
import eRpKit
import Nimble
import Pharmacy
import XCTest

@MainActor
class PharmacySearchDomainTests: XCTestCase {
    let testScheduler = DispatchQueue.test

    typealias TestStore = TestStoreOf<PharmacySearchDomain>

    // For tests we can lower the delay for search start
    var delaySearchStart: DispatchQueue.SchedulerTimeType.Stride = 0.1
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
        for state: PharmacySearchDomain.State,
        pharmacyRepository: PharmacyRepository = MockPharmacyRepository()
    ) -> TestStore {
        TestStore(initialState: state) {
            PharmacySearchDomain(referenceDateForOpenHours: TestData.openHoursTestReferenceDate)
        } withDependencies: { dependencies in
            dependencies.schedulers = Schedulers(uiScheduler: testScheduler.eraseToAnyScheduler())
            dependencies.pharmacyRepository = pharmacyRepository
            dependencies.locationManager = .failing
            dependencies.searchHistory = searchHistoryMock
            dependencies.resourceHandler = resourceHandlerMock
            dependencies.feedbackReceiver = MockFeedbackReceiver()
        }
    }

    func testSearchForPharmacies() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository(
            searchRemote: Just(TestData.pharmacies)
                .setFailureType(to: PharmacyRepositoryError.self)
                .eraseToAnyPublisher()
        )
        let sut = testStore(for: TestData.stateWithStartView, pharmacyRepository: mockPharmacyRepo)
        let testSearchText = "Apo"
        let expected: Result<[PharmacyLocation], PharmacyRepositoryError> = .success(TestData.pharmacies)

        searchHistoryMock.historyItemsReturnValue = []

        // when search text changes to valid search term...
        await sut.send(.searchTextChanged(testSearchText)) { state in
            // ...expect it to be stored
            state.searchText = testSearchText
        }
        // when user hits Enter on keyboard start search...
        await sut.send(.performSearch) { state in
            // ...expect a search request to run
            state.searchState = .searchRunning
        }
        await testScheduler.advance()
        // when search request is done...
        await sut.receive(.response(.pharmaciesReceived(expected))) { state in
            // expect it to deliver successful & results...
            state.searchState = .searchResultOk
        }
    }

    func testSearchForPharmaciesEmptyResult() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository(
            searchRemote: Just([])
                .setFailureType(to: PharmacyRepositoryError.self)
                .eraseToAnyPublisher()
        )
        let sut = testStore(for: TestData.stateEmpty, pharmacyRepository: mockPharmacyRepo)
        let testSearchText = "Apodfdfd"
        let expected: Result<[PharmacyLocation], PharmacyRepositoryError> = .success([])

        searchHistoryMock.historyItemsReturnValue = []

        // when search text changes to valid search term...
        await sut.send(.searchTextChanged(testSearchText)) { state in
            // ...expect it to be stored
            state.searchText = testSearchText
        }
        // when user hits Enter on keyboard start search...
        await sut.send(.performSearch) { state in
            // ...expect a search request to run
            state.searchState = .searchRunning
        }
        await testScheduler.advance()
        expect(self.searchHistoryMock.addHistoryItemReceivedItem).to(equal(testSearchText))
        // when search request is done...
        await sut.receive(.response(.pharmaciesReceived(expected))) { state in
            // expect it to be empty...
            state.searchState = .searchResultEmpty
        }
    }

    func testSearchForPharmaciesWithLocation() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository(
            searchRemote: Just(TestData.pharmaciesWithLocations)
                .setFailureType(to: PharmacyRepositoryError.self)
                .eraseToAnyPublisher()
        )
        let sut = testStore(for: TestData.stateWithLocation, pharmacyRepository: mockPharmacyRepo)
        let expected: Result<[PharmacyLocation], PharmacyRepositoryError> = .success(TestData.pharmaciesWithLocations)

        searchHistoryMock.historyItemsReturnValue = []

        // when user hits Location button start search...
        await sut.send(.performSearch) { state in
            // ...expect a search request to run
            state.searchState = .searchRunning
        }
        await testScheduler.advance()
        // when search request is done...
        await sut.receive(.response(.pharmaciesReceived(expected))) { state in
            // expect it to deliver successful & results...
            state.searchState = .searchResultOk
        }
    }

    func testStartView_loadLocalPharmacies_task_Success() async {
        let state = TestData.stateWithStartView
        let storedPharmacies = TestData.pharmacies
        let mockPharmacyRepo = MockPharmacyRepository(stored: storedPharmacies)
        let sut = testStore(for: state, pharmacyRepository: mockPharmacyRepo)
        searchHistoryMock.historyItemsReturnValue = []

        await sut.send(.task)
        await testScheduler.advance()
        await sut.receive(.response(.loadLocalPharmaciesReceived(.success(storedPharmacies)))) {
            $0.localPharmacies = storedPharmacies
                .map { PharmacyLocationViewModel(pharmacy: $0, referenceDate: TestData.openHoursTestReferenceDate) }
        }
    }

    func testStartView_selectingLocalPharmacies_toLoadAndNavigateToPharmacy_Success() async {
        let state = TestData.stateWithStartView
        let selectedPharmacy = PharmacyLocation.Fixtures.pharmacyA
        let mockPharmacyRepo = MockPharmacyRepository(
            loadRemoteAndSave: Just(selectedPharmacy).setFailureType(to: PharmacyRepositoryError.self)
                .eraseToAnyPublisher()
        )
        let sut = testStore(for: state, pharmacyRepository: mockPharmacyRepo)
        searchHistoryMock.historyItemsReturnValue = []

        await sut.send(.loadAndNavigateToPharmacy(selectedPharmacy)) {
            $0.searchState = .startView(loading: true)
            $0.selectedPharmacy = selectedPharmacy
        }
        await testScheduler.advance()
        await sut.receive(.response(.loadAndNavigateToPharmacyReceived(.success(selectedPharmacy)))) {
            $0.searchState = .startView(loading: false)
            $0.selectedPharmacy = nil
            $0.destination = .pharmacy(PharmacyDetailDomain.State(
                erxTasks: state.erxTasks,
                pharmacyViewModel: PharmacyLocationViewModel(
                    pharmacy: selectedPharmacy,
                    referenceDate: TestData.openHoursTestReferenceDate
                )
            ))
        }
    }

    func testStartView_selectingLocalPharmacies_toLoadAndNavigateToPharmacy_Failure() async {
        let state = TestData.stateWithStartView
        let selectedPharmacy = PharmacyLocation.Fixtures.pharmacyA
        let expectedError = PharmacyRepositoryError.remote(.fhirClient(.inconsistentResponse))
        let mockPharmacyRepo = MockPharmacyRepository(
            loadRemoteAndSave: Fail(error: expectedError).eraseToAnyPublisher()
        )
        let sut = testStore(for: state, pharmacyRepository: mockPharmacyRepo)
        searchHistoryMock.historyItemsReturnValue = []

        await sut.send(.loadAndNavigateToPharmacy(selectedPharmacy)) {
            $0.searchState = .startView(loading: true)
            $0.selectedPharmacy = selectedPharmacy
        }
        await testScheduler.advance()
        await sut.receive(.response(.loadAndNavigateToPharmacyReceived(.failure(expectedError)))) {
            $0.searchState = .startView(loading: false)
            $0.selectedPharmacy = nil
            $0.destination = .alert(.init(for: expectedError))
        }
    }

    func testStartView_selectingLocalPharmacies_toLoadAndNavigateToPharmacy_NotFound() async {
        let pharmacyViewModels = TestData.pharmacies.map { pharmacies in
            PharmacyLocationViewModel(
                pharmacy: pharmacies,
                referenceLocation: nil,
                referenceDate: TestData.openHoursTestReferenceDate
            )
        }
        let state = PharmacySearchDomain.State(
            erxTasks: [ErxTask.Fixtures.erxTaskReady],
            searchText: "",
            pharmacies: pharmacyViewModels,
            localPharmacies: pharmacyViewModels,
            searchState: .startView(loading: false)
        )
        let selectedPharmacy = pharmacyViewModels.last!
        let expectedError = PharmacyRepositoryError.remote(.notFound)
        let mockPharmacyRepo = MockPharmacyRepository(
            loadRemoteAndSave: Fail(error: expectedError).eraseToAnyPublisher(),
            deletePharmacies: Just(true).setFailureType(to: PharmacyRepositoryError.self).eraseToAnyPublisher()
        )
        let sut = testStore(for: state, pharmacyRepository: mockPharmacyRepo)
        searchHistoryMock.historyItemsReturnValue = []

        await sut.send(.loadAndNavigateToPharmacy(selectedPharmacy.pharmacyLocation)) {
            $0.searchState = .startView(loading: true)
            $0.selectedPharmacy = selectedPharmacy.pharmacyLocation
        }
        await testScheduler.advance()
        await sut.receive(.response(.loadAndNavigateToPharmacyReceived(.failure(expectedError)))) {
            $0.searchState = .startView(loading: false)
            $0.selectedPharmacy = nil
            $0.localPharmacies = pharmacyViewModels.dropLast()
            $0.destination = .alert(.init(for: expectedError))
        }
        expect(mockPharmacyRepo.deleteCallsCount) == 1
    }

    func test_requestAuthorization_WhenInUse() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository(
            searchRemote: Just(TestData.pharmacies)
                .setFailureType(to: PharmacyRepositoryError.self)
                .eraseToAnyPublisher()
        )
        let sut = testStore(for: TestData.stateWithStartView, pharmacyRepository: mockPharmacyRepo)
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        sut.dependencies.locationManager.authorizationStatus = { .notDetermined }
        sut.dependencies.locationManager.delegate = { .publisher(locationManagerSubject.eraseToAnyPublisher) }
        sut.dependencies.locationManager.requestWhenInUseAuthorization = { .run { _ in } }
        // when
        await sut.send(.onAppear)
        await sut.send(.requestLocation)
        locationManagerSubject.send(.didChangeAuthorization(.authorizedWhenInUse))
        // then
        await sut.receive(.locationManager(.didChangeAuthorization(.authorizedWhenInUse)))
        locationManagerSubject.send(completion: .finished)
    }

    func test_requestAuthorization_Denied() async {
        // given
        let mockPharmacyRepo = MockPharmacyRepository(
            searchRemote: Just(TestData.pharmacies)
                .setFailureType(to: PharmacyRepositoryError.self)
                .eraseToAnyPublisher()
        )
        let sut = testStore(for: TestData.stateWithStartView, pharmacyRepository: mockPharmacyRepo)
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        sut.dependencies.locationManager.authorizationStatus = { .denied }
        sut.dependencies.locationManager.delegate = { .publisher(locationManagerSubject.eraseToAnyPublisher) }
        sut.dependencies.locationManager.requestWhenInUseAuthorization = { .run { _ in } }
        // when
        await sut.send(.onAppear)
        await sut.send(.requestLocation) { state in
            state.destination = .alert(PharmacySearchDomain.locationPermissionAlertState)
        }
        locationManagerSubject.send(.didChangeAuthorization(.denied))
        // then
        await sut.receive(.locationManager(.didChangeAuthorization(.denied)))
        locationManagerSubject.send(completion: .finished)
    }

    func testUniversalLink() async {
        let mockPharmacyRepo = MockPharmacyRepository()
        let pharmacy = PharmacyLocation(id: "123.456.789", telematikID: "123.456.789", types: [])
        mockPharmacyRepo.loadCachedPublisher = Just(pharmacy)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        mockPharmacyRepo.savePublisher = Just(false)
            .setFailureType(to: PharmacyRepositoryError.self)
            .eraseToAnyPublisher()
        let sut = testStore(for: PharmacySearchDomain.State(
            erxTasks: [],
            searchText: "",
            pharmacies: []
        ), pharmacyRepository: mockPharmacyRepo)

        let url = URL(string: "https://erezept.gematik.de/pharmacies/#tiid=123.456.789")!
        await sut.send(.universalLink(url)) { state in
            state.searchState = .startView(loading: true)
        }
        var locationViewModel = PharmacyLocationViewModel(pharmacy: pharmacy)
        await sut.receive(.response(.loadAndNavigateToPharmacyReceived(.success(pharmacy)))) { state in
            state.searchState = .startView(loading: false)

            state
                .destination = .pharmacy(PharmacyDetailDomain.State(erxTasks: [], pharmacyViewModel: locationViewModel))
        }

        await testScheduler.run()

        await sut.receive(.destination(.presented(.pharmacyDetailView(action: .setIsFavorite(true)))))

        await testScheduler.run()
        locationViewModel.pharmacyLocation.isFavorite = true
        await sut
            .receive(
                .destination(
                    .presented(
                        .pharmacyDetailView(action: .response(.toggleIsFavoriteReceived(.success(locationViewModel))))
                    )
                )
            ) { state in
                state
                    .destination = .pharmacy(PharmacyDetailDomain
                        .State(erxTasks: [], pharmacyViewModel: locationViewModel))
            }
    }
}

extension PharmacySearchDomainTests {
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
        public static let stateWithStartView =
            PharmacySearchDomain.State(
                erxTasks: [ErxTask.Fixtures.erxTaskReady],
                searchText: "",
                pharmacies: pharmacies.map { pharmacies in
                    PharmacyLocationViewModel(
                        pharmacy: pharmacies,
                        referenceLocation: nil,
                        referenceDate: TestData.openHoursTestReferenceDate
                    )
                },
                searchState: .startView(loading: false)
            )
        /// Test-Data PharmacyDomain.State
        public static let stateEmpty =
            PharmacySearchDomain.State(
                erxTasks: [ErxTask.Fixtures.erxTaskReady],
                searchText: "",
                pharmacies: []
            )
        /// Test-Data PharmacyDomain.State with a location
        public static let stateWithLocation =
            PharmacySearchDomain.State(
                erxTasks: [ErxTask.Fixtures.erxTaskReady],
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
